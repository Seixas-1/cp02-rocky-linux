#!/usr/bin/env bash
#===============================================================================
#  user-audit.sh — Auditoria de contas, senhas e privilégios
#
#  CP 02 — Ambiente Linux (RHEL) · Grupo 2 · Rocky Linux
#  FIAP — Sistemas Operacionais Linux / Cibersegurança
#
#  ESTE SCRIPT É SOMENTE DE LEITURA. Ele não cria, altera nem remove contas,
#  senhas, arquivos de configuração ou regras de sudo. Toda correção apontada
#  no relatório é aplicada manualmente pelo administrador. Por consequência é
#  naturalmente idempotente: executar duas vezes produz o mesmo estado final
#  do sistema (apenas o arquivo de log recebe novas linhas).
#
#  Verificações realizadas:
#    1) contas com UID 0 além de root
#    2) contas com senha vazia em /etc/shadow
#    3) contas de sistema com shell de login válido
#    4) envelhecimento de senha fora da política (campos geridos pelo chage)
#    5) contas humanas paradas há mais de N dias
#    6) diretivas NOPASSWD em /etc/sudoers e /etc/sudoers.d
#    7) política de complexidade de senha (pwquality)
#
#  Códigos de saída:
#    0  execução concluída sem nenhum achado
#    1  execução concluída com pelo menos um achado
#    2  erro de uso (opção inválida ou argumento ausente)
#    3  dependência ausente ou privilégio insuficiente
#===============================================================================

set -euo pipefail

# Torna determinística a saída dos utilitários do sistema (datas, "Never logged
# in", etc.). As mensagens exibidas ao usuário são literais em português dentro
# do próprio script, portanto não são afetadas por esta definição.
export LC_ALL=C

#-------------------------------------------------------------------------------
# Constantes
#-------------------------------------------------------------------------------
readonly VERSAO="1.0.0"
NOME_SCRIPT="$(basename "$0")"
readonly NOME_SCRIPT

readonly ARQUIVO_LOG="/var/log/user-audit.log"

readonly EX_OK=0
readonly EX_ACHADO=1
readonly EX_USO=2
readonly EX_DEPENDENCIA=3

# Baseline da política de senha (dias). Campos numéricos de /etc/shadow, que são
# exatamente os campos que o utilitário chage lê e escreve.
readonly SENHA_MAX_DIAS=90    # PASS_MAX_DAYS máximo aceitável
readonly SENHA_MIN_DIAS=1     # PASS_MIN_DAYS mínimo aceitável
readonly SENHA_AVISO_DIAS=7   # PASS_WARN_AGE mínimo aceitável

# Baseline de complexidade (pwquality), inspirada no CIS Benchmark.
readonly PWQ_MINLEN_MIN=14
readonly PWQ_MINCLASS_MIN=4
readonly PWQ_MAXREPEAT_MAX=3
readonly PWQ_DIFOK_MIN=2
readonly PWQ_RETRY_MAX=3

#-------------------------------------------------------------------------------
# Variáveis globais mutáveis
#-------------------------------------------------------------------------------
DIAS_INATIVIDADE=90
ARQUIVO_SAIDA=""
MODO_SILENCIOSO=0
USAR_COR=1
TOTAL_ACHADOS=0
TOTAL_AVISOS=0
DIR_TEMP=""
RELATORIO=""

COR_RESET=""
COR_VERMELHO=""
COR_AMARELO=""
COR_VERDE=""
COR_NEGRITO=""

#-------------------------------------------------------------------------------
# Infraestrutura: ajuda, log, limpeza, emissão do relatório
#-------------------------------------------------------------------------------

exibir_ajuda() {
    cat <<AJUDA
${NOME_SCRIPT} v${VERSAO} — Auditoria de contas, senhas e privilégios

USO:
    ${NOME_SCRIPT} [OPÇÕES]

DESCRIÇÃO:
    Audita a base local de contas de um sistema Rocky Linux / RHEL procurando
    por desvios de política em contas privilegiadas, senhas e regras de sudo.
    O script é SOMENTE DE LEITURA: nenhuma alteração é feita no sistema.

OPÇÕES:
    -d, --dias N        Limiar de inatividade em dias (padrão: ${DIAS_INATIVIDADE}).
    -s, --saida ARQUIVO Grava o relatório também no arquivo indicado.
    -q, --silencioso    Suprime as linhas de log no terminal (o arquivo de
                        log continua sendo gravado).
        --sem-cor       Desativa os códigos de cor na saída.
    -v, --versao        Exibe a versão e termina.
    -h, --help          Exibe esta ajuda e termina.

CÓDIGOS DE SAÍDA:
    0   nenhum achado
    1   pelo menos um achado
    2   erro de uso
    3   dependência ausente ou privilégio insuficiente

ARQUIVO DE LOG:
    ${ARQUIVO_LOG}

EXEMPLOS:
    sudo ${NOME_SCRIPT}
    sudo ${NOME_SCRIPT} --dias 60 --saida /tmp/relatorio-user-audit.txt
    sudo ${NOME_SCRIPT} --silencioso --sem-cor > evidencias/04-script/execucao.txt
AJUDA
}

registrar_log() {
    local nivel="$1"
    shift
    local mensagem="$*"
    local carimbo
    carimbo="$(date '+%Y-%m-%d %H:%M:%S')"
    local linha="${carimbo} [${nivel}] ${mensagem}"

    # O log em disco é sempre gravado quando o caminho é acessível.
    if [[ -w "$ARQUIVO_LOG" ]] || [[ -w "$(dirname "$ARQUIVO_LOG")" ]]; then
        printf '%s\n' "$linha" >> "$ARQUIVO_LOG"
    fi

    # As linhas de log vão para stderr para não poluir o relatório em stdout.
    if (( MODO_SILENCIOSO == 0 )); then
        case "$nivel" in
            ERROR) printf '%s%s%s\n' "$COR_VERMELHO" "$linha" "$COR_RESET" >&2 ;;
            WARN)  printf '%s%s%s\n' "$COR_AMARELO"  "$linha" "$COR_RESET" >&2 ;;
            *)     printf '%s\n' "$linha" >&2 ;;
        esac
    fi
}

limpar() {
    if [[ -n "$DIR_TEMP" && -d "$DIR_TEMP" ]]; then
        rm -rf "$DIR_TEMP"
    fi
}

definir_cores() {
    # Cor só faz sentido em terminal interativo e quando o relatório não está
    # sendo desviado para arquivo.
    if (( USAR_COR == 1 )) && [[ -t 1 ]] && [[ -z "$ARQUIVO_SAIDA" ]]; then
        COR_RESET=$'\033[0m'
        COR_VERMELHO=$'\033[31m'
        COR_AMARELO=$'\033[33m'
        COR_VERDE=$'\033[32m'
        COR_NEGRITO=$'\033[1m'
    fi
}

emitir() {
    printf '%s\n' "$*" >> "$RELATORIO"
}

ok() {
    emitir "  ${COR_VERDE}[ OK      ]${COR_RESET} $*"
}

alerta() {
    emitir "  ${COR_AMARELO}[ AVISO   ]${COR_RESET} $*"
    TOTAL_AVISOS=$(( TOTAL_AVISOS + 1 ))
}

falha() {
    emitir "  ${COR_VERMELHO}[ ACHADO  ]${COR_RESET} $*"
    TOTAL_ACHADOS=$(( TOTAL_ACHADOS + 1 ))
}

detalhe() {
    emitir "               $*"
}

secao() {
    emitir ""
    emitir "${COR_NEGRITO}$*${COR_RESET}"
}

#-------------------------------------------------------------------------------
# Pré-condições
#-------------------------------------------------------------------------------

verificar_privilegio() {
    # A leitura de /etc/shadow e de /etc/sudoers.d exige privilégio de root.
    if (( EUID != 0 )); then
        registrar_log ERROR "Este script precisa ser executado como root (EUID atual: ${EUID})."
        registrar_log ERROR "Use: sudo ${NOME_SCRIPT}"
        exit "$EX_DEPENDENCIA"
    fi
    registrar_log INFO "Privilégio verificado: executando como root."
}

verificar_dependencias() {
    local -a obrigatorias=(awk sed sort getent chage)
    local -a ausentes=()
    local comando

    for comando in "${obrigatorias[@]}"; do
        if ! command -v "$comando" >/dev/null 2>&1; then
            ausentes+=("$comando")
        fi
    done

    if (( ${#ausentes[@]} > 0 )); then
        registrar_log ERROR "Dependências obrigatórias ausentes: ${ausentes[*]}"
        exit "$EX_DEPENDENCIA"
    fi

    # Dependências opcionais: a verificação correspondente é degradada, não abortada.
    for comando in lastlog visudo; do
        if ! command -v "$comando" >/dev/null 2>&1; then
            registrar_log WARN "Dependência opcional ausente: ${comando} (verificação parcial)."
        fi
    done

    registrar_log INFO "Todas as dependências obrigatórias estão presentes."
}

preparar_ambiente() {
    DIR_TEMP="$(mktemp -d -t user-audit.XXXXXXXX)"
    trap limpar EXIT
    RELATORIO="${DIR_TEMP}/relatorio.txt"
    : > "$RELATORIO"
    registrar_log INFO "Diretório temporário criado em ${DIR_TEMP}."
}

#-------------------------------------------------------------------------------
# Utilitários de consulta
#-------------------------------------------------------------------------------

obter_uid_min() {
    local uid_min
    uid_min="$(awk '/^UID_MIN[[:space:]]/ { print $2 }' /etc/login.defs 2>/dev/null | tail -n 1)"
    [[ -n "$uid_min" ]] || uid_min=1000
    printf '%s' "$uid_min"
}

listar_usuarios_humanos() {
    local uid_min uid_max
    uid_min="$(obter_uid_min)"
    uid_max="$(awk '/^UID_MAX[[:space:]]/ { print $2 }' /etc/login.defs 2>/dev/null | tail -n 1)"
    [[ -n "$uid_max" ]] || uid_max=60000

    awk -F: -v min="$uid_min" -v max="$uid_max" \
        '$3 >= min && $3 <= max { print $1 }' /etc/passwd | sort
}

#-------------------------------------------------------------------------------
# Verificação 1 — contas com UID 0
#-------------------------------------------------------------------------------

checar_uid_zero_duplicado() {
    secao "1) Contas com UID 0"
    local -a contas
    mapfile -t contas < <(awk -F: '$3 == 0 { print $1 }' /etc/passwd)

    if (( ${#contas[@]} <= 1 )); then
        ok "Somente a conta root possui UID 0."
        return 0
    fi

    falha "Existem ${#contas[@]} contas com UID 0 — esperado apenas root."
    local conta
    for conta in "${contas[@]}"; do
        detalhe "UID 0: ${conta}"
    done
    detalhe "Correção manual: usermod -u <novo_uid> <conta>, ou remover a conta."
}

#-------------------------------------------------------------------------------
# Verificação 2 — senhas vazias
#-------------------------------------------------------------------------------

checar_senha_vazia() {
    secao "2) Contas com senha vazia"
    local -a contas
    # Campo 2 vazio em /etc/shadow significa login sem senha. Os valores "!",
    # "!!" e "*" indicam conta bloqueada e são estados legítimos.
    mapfile -t contas < <(awk -F: '$2 == "" { print $1 }' /etc/shadow)

    if (( ${#contas[@]} == 0 )); then
        ok "Nenhuma conta com senha vazia."
        return 0
    fi

    falha "Existem ${#contas[@]} conta(s) que autenticam sem senha."
    local conta
    for conta in "${contas[@]}"; do
        detalhe "senha vazia: ${conta}"
    done
    detalhe "Correção manual: passwd -l <conta> para bloquear, ou definir senha."
}

#-------------------------------------------------------------------------------
# Verificação 3 — contas de sistema com shell de login
#-------------------------------------------------------------------------------

checar_conta_sistema_com_shell() {
    secao "3) Contas de sistema com shell de login válido"
    local uid_min
    uid_min="$(obter_uid_min)"

    local -a contas
    # Contas abaixo de UID_MIN (exceto root) são de serviço e não devem permitir
    # login interativo. As contas sync/shutdown/halt são exceções históricas com
    # shell próprio e propósito conhecido.
    mapfile -t contas < <(
        awk -F: -v min="$uid_min" '
            $3 < min && $3 != 0 &&
            $1 != "sync" && $1 != "shutdown" && $1 != "halt" &&
            $7 !~ /(nologin|false)$/ { print $1" -> "$7 }
        ' /etc/passwd
    )

    if (( ${#contas[@]} == 0 )); then
        ok "Nenhuma conta de sistema (UID < ${uid_min}) possui shell de login."
        return 0
    fi

    falha "Existem ${#contas[@]} conta(s) de sistema com shell de login."
    local conta
    for conta in "${contas[@]}"; do
        detalhe "$conta"
    done
    detalhe "Correção manual: usermod -s /sbin/nologin <conta>."
}

#-------------------------------------------------------------------------------
# Verificação 4 — envelhecimento de senha
#-------------------------------------------------------------------------------

checar_envelhecimento_senha() {
    secao "4) Envelhecimento de senha das contas humanas"
    local -a usuarios
    mapfile -t usuarios < <(listar_usuarios_humanos)

    if (( ${#usuarios[@]} == 0 )); then
        alerta "Nenhuma conta humana encontrada para auditar."
        return 0
    fi

    local usuario campos minimo maximo aviso
    local conformes=0
    local -a irregulares=()

    for usuario in "${usuarios[@]}"; do
        # Campos 4, 5 e 6 de /etc/shadow: PASS_MIN_DAYS, PASS_MAX_DAYS e
        # PASS_WARN_AGE. São os mesmos campos manipulados pelo chage; lê-los
        # diretamente evita depender do formato textual de "chage -l".
        campos="$(awk -F: -v u="$usuario" '$1 == u { print $4":"$5":"$6 }' /etc/shadow)"
        [[ -n "$campos" ]] || continue

        IFS=':' read -r minimo maximo aviso <<< "$campos"
        [[ -n "$minimo" ]] || minimo=0
        [[ -n "$maximo" ]] || maximo=99999
        [[ -n "$aviso"  ]] || aviso=0

        local -a problemas=()
        if (( maximo > SENHA_MAX_DIAS )); then
            problemas+=("PASS_MAX_DAYS=${maximo} (máximo aceitável: ${SENHA_MAX_DIAS})")
        fi
        if (( minimo < SENHA_MIN_DIAS )); then
            problemas+=("PASS_MIN_DAYS=${minimo} (mínimo aceitável: ${SENHA_MIN_DIAS})")
        fi
        if (( aviso < SENHA_AVISO_DIAS )); then
            problemas+=("PASS_WARN_AGE=${aviso} (mínimo aceitável: ${SENHA_AVISO_DIAS})")
        fi

        if (( ${#problemas[@]} == 0 )); then
            conformes=$(( conformes + 1 ))
        else
            irregulares+=("${usuario}|${problemas[*]}")
        fi
    done

    if (( ${#irregulares[@]} == 0 )); then
        ok "As ${conformes} conta(s) humana(s) estão dentro da política de envelhecimento."
        return 0
    fi

    falha "${#irregulares[@]} de ${#usuarios[@]} conta(s) humana(s) fora da política."
    local registro
    for registro in "${irregulares[@]}"; do
        detalhe "${registro%%|*}: ${registro#*|}"
    done
    detalhe "Correção manual: chage -M ${SENHA_MAX_DIAS} -m ${SENHA_MIN_DIAS} -W ${SENHA_AVISO_DIAS} <conta>."
    detalhe "Padrão para contas novas: PASS_MAX_DAYS/PASS_MIN_DAYS/PASS_WARN_AGE em /etc/login.defs."
}

#-------------------------------------------------------------------------------
# Verificação 5 — contas paradas
#-------------------------------------------------------------------------------

checar_contas_inativas() {
    secao "5) Contas humanas sem acesso há mais de ${DIAS_INATIVIDADE} dias"

    if ! command -v lastlog >/dev/null 2>&1; then
        alerta "Utilitário lastlog indisponível — verificação não executada."
        detalhe "Em versões recentes do shadow-utils o lastlog foi substituído pelo lastlog2."
        return 0
    fi

    local -a usuarios
    mapfile -t usuarios < <(listar_usuarios_humanos)

    local usuario saida
    local -a nunca=()
    local -a paradas=()

    for usuario in "${usuarios[@]}"; do
        # "lastlog -b N" lista apenas registros mais antigos que N dias; a
        # primeira linha da saída é o cabeçalho e é descartada.
        saida="$(lastlog -b "$DIAS_INATIVIDADE" -u "$usuario" 2>/dev/null | tail -n +2)"
        [[ -n "$saida" ]] || continue

        if [[ "$saida" == *"Never logged in"* ]]; then
            nunca+=("$usuario")
        else
            paradas+=("$usuario")
        fi
    done

    if (( ${#nunca[@]} == 0 && ${#paradas[@]} == 0 )); then
        ok "Nenhuma conta humana parada além do limiar de ${DIAS_INATIVIDADE} dias."
        return 0
    fi

    falha "$(( ${#nunca[@]} + ${#paradas[@]} )) conta(s) humana(s) sem uso recente."
    local usuario_listado
    for usuario_listado in "${paradas[@]}"; do
        detalhe "sem acesso há mais de ${DIAS_INATIVIDADE} dias: ${usuario_listado}"
    done
    for usuario_listado in "${nunca[@]}"; do
        detalhe "nunca acessou o sistema: ${usuario_listado}"
    done
    detalhe "Correção manual: usermod -L <conta> para bloquear, ou userdel se obsoleta."
}

#-------------------------------------------------------------------------------
# Verificação 6 — NOPASSWD no sudoers
#-------------------------------------------------------------------------------

checar_sudoers_nopasswd() {
    secao "6) Diretivas NOPASSWD em sudoers"
    local -a ocorrencias

    # Linhas comentadas são descartadas; o alvo é apenas a regra efetiva.
    mapfile -t ocorrencias < <(
        grep -rEn '^[[:space:]]*[^#]*NOPASSWD' /etc/sudoers /etc/sudoers.d 2>/dev/null || true
    )

    if (( ${#ocorrencias[@]} == 0 )); then
        ok "Nenhuma regra NOPASSWD ativa em /etc/sudoers ou /etc/sudoers.d."
    else
        falha "${#ocorrencias[@]} regra(s) NOPASSWD ativa(s) — sudo sem reautenticação."
        local ocorrencia
        for ocorrencia in "${ocorrencias[@]}"; do
            detalhe "$ocorrencia"
        done
        detalhe "Correção manual: editar com visudo e remover o modificador NOPASSWD."
    fi

    # A sintaxe inválida do sudoers pode inviabilizar toda escalada legítima.
    if command -v visudo >/dev/null 2>&1; then
        if visudo -c >/dev/null 2>&1; then
            ok "Sintaxe de /etc/sudoers validada pelo visudo."
        else
            falha "visudo -c apontou erro de sintaxe em sudoers."
            detalhe "Correção manual: visudo -c para ver o erro; corrigir antes de reiniciar."
        fi
    fi
}

#-------------------------------------------------------------------------------
# Verificação 7 — política de complexidade (pwquality)
#-------------------------------------------------------------------------------

ler_parametro_pwquality() {
    local chave="$1"
    local valor=""
    local arquivo encontrado

    # Precedência: os arquivos de pwquality.conf.d sobrescrevem pwquality.conf.
    # Percorremos na mesma ordem e mantemos o último valor encontrado.
    for arquivo in /etc/security/pwquality.conf /etc/security/pwquality.conf.d/*.conf; do
        [[ -r "$arquivo" ]] || continue
        encontrado="$(
            sed -nE "s/^[[:space:]]*${chave}[[:space:]]*=[[:space:]]*([^[:space:]#]+).*/\1/p" \
                "$arquivo" | tail -n 1
        )"
        if [[ -n "$encontrado" ]]; then
            valor="$encontrado"
        fi
    done

    printf '%s' "$valor"
    return 0
}

avaliar_parametro_pwquality() {
    local chave="$1" operador="$2" esperado="$3" valor="$4"

    if [[ -z "$valor" ]]; then
        falha "${chave} não definido — vale o padrão da biblioteca, não a política do grupo."
        return 0
    fi

    if [[ ! "$valor" =~ ^-?[0-9]+$ ]]; then
        alerta "${chave}=${valor} não é numérico — verificação ignorada."
        return 0
    fi

    case "$operador" in
        min)
            if (( valor >= esperado )); then
                ok "${chave}=${valor} (mínimo exigido: ${esperado})."
            else
                falha "${chave}=${valor} abaixo do mínimo exigido (${esperado})."
            fi
            ;;
        max)
            if (( valor <= esperado )); then
                ok "${chave}=${valor} (máximo permitido: ${esperado})."
            else
                falha "${chave}=${valor} acima do máximo permitido (${esperado})."
            fi
            ;;
    esac
}

checar_pwquality() {
    secao "7) Política de complexidade de senha (pwquality)"

    if [[ ! -r /etc/security/pwquality.conf ]]; then
        falha "/etc/security/pwquality.conf ausente ou ilegível."
        detalhe "Correção manual: instalar libpwquality e configurar a política."
        return 0
    fi

    avaliar_parametro_pwquality minlen    min "$PWQ_MINLEN_MIN"    "$(ler_parametro_pwquality minlen)"
    avaliar_parametro_pwquality minclass  min "$PWQ_MINCLASS_MIN"  "$(ler_parametro_pwquality minclass)"
    avaliar_parametro_pwquality difok     min "$PWQ_DIFOK_MIN"     "$(ler_parametro_pwquality difok)"
    avaliar_parametro_pwquality maxrepeat max "$PWQ_MAXREPEAT_MAX" "$(ler_parametro_pwquality maxrepeat)"
    avaliar_parametro_pwquality retry     max "$PWQ_RETRY_MAX"     "$(ler_parametro_pwquality retry)"

    # Sem enforce_for_root a política não vale para senhas definidas pelo root.
    if [[ -n "$(ler_parametro_pwquality enforce_for_root)" ]]; then
        ok "enforce_for_root habilitado — a política também vale para o root."
    else
        alerta "enforce_for_root ausente — senhas definidas pelo root escapam da política."
    fi

    # De nada adianta a configuração se o módulo não estiver na pilha do PAM.
    if grep -rq 'pam_pwquality.so' /etc/pam.d/ 2>/dev/null; then
        ok "Módulo pam_pwquality.so presente na pilha do PAM."
    else
        falha "pam_pwquality.so não encontrado em /etc/pam.d — a política não é aplicada."
        detalhe "Correção manual (Rocky/RHEL): authselect enable-feature with-pwquality."
    fi
}

#-------------------------------------------------------------------------------
# Relatório
#-------------------------------------------------------------------------------

escrever_cabecalho() {
    local nome_so="desconhecido"
    if [[ -r /etc/os-release ]]; then
        nome_so="$(awk -F= '/^PRETTY_NAME=/ { gsub(/"/, "", $2); print $2 }' /etc/os-release)"
    fi

    emitir "==============================================================================="
    emitir " RELATÓRIO DE AUDITORIA DE CONTAS, SENHAS E PRIVILÉGIOS"
    emitir " ${NOME_SCRIPT} v${VERSAO} — somente leitura, nenhuma alteração aplicada"
    emitir "==============================================================================="
    emitir " Host ............: ${HOSTNAME:-desconhecido}"
    emitir " Sistema .........: ${nome_so}"
    emitir " Kernel ..........: $(uname -r)"
    emitir " Data/hora .......: $(date '+%Y-%m-%d %H:%M:%S %Z')"
    emitir " Limiar inativid. : ${DIAS_INATIVIDADE} dias"
    emitir "==============================================================================="
}

escrever_resumo() {
    emitir ""
    emitir "==============================================================================="
    emitir " RESUMO"
    emitir "==============================================================================="
    emitir " Achados .........: ${TOTAL_ACHADOS}"
    emitir " Avisos ..........: ${TOTAL_AVISOS}"

    if (( TOTAL_ACHADOS == 0 )); then
        emitir " Veredito ........: ${COR_VERDE}conforme com a baseline do grupo${COR_RESET}"
    else
        emitir " Veredito ........: ${COR_VERMELHO}não conforme — revisar os itens acima${COR_RESET}"
    fi
    emitir "==============================================================================="
}

publicar_relatorio() {
    cat "$RELATORIO"

    if [[ -n "$ARQUIVO_SAIDA" ]]; then
        if cp -- "$RELATORIO" "$ARQUIVO_SAIDA"; then
            registrar_log INFO "Relatório gravado em ${ARQUIVO_SAIDA}."
        else
            registrar_log ERROR "Não foi possível gravar o relatório em ${ARQUIVO_SAIDA}."
        fi
    fi
}

#-------------------------------------------------------------------------------
# Argumentos
#-------------------------------------------------------------------------------

analisar_argumentos() {
    while (( $# > 0 )); do
        case "$1" in
            -h|--help)
                exibir_ajuda
                exit "$EX_OK"
                ;;
            -v|--versao|--version)
                printf '%s v%s\n' "$NOME_SCRIPT" "$VERSAO"
                exit "$EX_OK"
                ;;
            -d|--dias)
                if [[ -z "${2:-}" ]]; then
                    printf 'Erro: a opção %s exige um argumento.\n' "$1" >&2
                    exit "$EX_USO"
                fi
                if [[ ! "$2" =~ ^[0-9]+$ ]] || (( $2 == 0 )); then
                    printf 'Erro: "%s" não é um número de dias válido.\n' "$2" >&2
                    exit "$EX_USO"
                fi
                DIAS_INATIVIDADE="$2"
                shift 2
                ;;
            -s|--saida)
                if [[ -z "${2:-}" ]]; then
                    printf 'Erro: a opção %s exige um argumento.\n' "$1" >&2
                    exit "$EX_USO"
                fi
                ARQUIVO_SAIDA="$2"
                shift 2
                ;;
            -q|--silencioso)
                MODO_SILENCIOSO=1
                shift
                ;;
            --sem-cor)
                USAR_COR=0
                shift
                ;;
            --)
                shift
                break
                ;;
            *)
                printf 'Erro: opção desconhecida "%s".\n' "$1" >&2
                printf 'Use "%s --help" para ver as opções disponíveis.\n' "$NOME_SCRIPT" >&2
                exit "$EX_USO"
                ;;
        esac
    done
}

#-------------------------------------------------------------------------------
# Fluxo principal
#-------------------------------------------------------------------------------

principal() {
    analisar_argumentos "$@"
    definir_cores

    verificar_privilegio
    verificar_dependencias
    preparar_ambiente

    registrar_log INFO "Início da auditoria (limiar de inatividade: ${DIAS_INATIVIDADE} dias)."

    escrever_cabecalho
    checar_uid_zero_duplicado
    checar_senha_vazia
    checar_conta_sistema_com_shell
    checar_envelhecimento_senha
    checar_contas_inativas
    checar_sudoers_nopasswd
    checar_pwquality
    escrever_resumo

    publicar_relatorio

    registrar_log INFO "Auditoria concluída: ${TOTAL_ACHADOS} achado(s), ${TOTAL_AVISOS} aviso(s)."

    if (( TOTAL_ACHADOS > 0 )); then
        exit "$EX_ACHADO"
    fi
    exit "$EX_OK"
}

principal "$@"
