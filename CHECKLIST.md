# Checklist de entrega — Grupo 2 · Rocky Linux

Data da apresentação (D-0): **__/__/____**

---

## Marcos

| Marco | Data | Item | Status |
|---|---|---|---|
| D-21 | __/__/____ | Grupo formado, distribuição atribuída | [ ] |
| D-18 | __/__/____ | Repositório criado, VM preparada | [ ] |
| **D-14** | __/__/____ | **Diagrama validado — submetido ANTES de instalar (não opcional)** | [ ] |
| D-10 | __/__/____ | Instalação concluída, evidências de disco/LVM/LUKS | [ ] |
| D-7 | __/__/____ | SSH endurecido, primeira versão do script | [ ] |
| D-3 | __/__/____ | Pesquisa e guia de instalação finalizados | [ ] |
| D-2 | __/__/____ | Slides prontos e **gabarito entregue (48h de antecedência)** | [ ] |
| D-0 | __/__/____ | Apresentação de 30 minutos | [ ] |

---

## Entregável 01 — Documento de pesquisa (8 pts)

- [ ] PDF com **12 a 20 páginas**
- [ ] **Mínimo 8 referências**, sendo **4 primárias**
- [ ] Cobre o recorte do grupo: RESF, *bug-for-bug*, Peridot, fim do CentOS
- [ ] Toda afirmação tem evidência correspondente em `evidencias/`

## Entregável 02 — Apresentação (15 pts)

- [ ] `.pptx` **e** PDF no repositório
- [ ] **20 a 30 slides**
- [ ] Máximo **30 minutos** (−2 pontos por minuto excedido)
- [ ] **Todos os integrantes apresentam** alguma parte
- [ ] Slide de pergunta seguido do slide de resposta comentada

## Entregável 03 — Guia de instalação (8 pts)

- [ ] `INSTALL.md` reproduzível do zero
- [ ] Diagrama do particionamento
- [ ] Prints da instalação
- [ ] **Seção de troubleshooting com problemas reais do grupo**

## Entregável 04 — Script `user-audit.sh` (20 pts)

Requisitos do grupo (10 pts) — o script detecta:
- [ ] UID 0 duplicado
- [ ] Senha vazia
- [ ] Conta de sistema com shell válido
- [ ] Envelhecimento de senha via `chage`
- [ ] Contas paradas há 90 dias
- [ ] `NOPASSWD` no sudoers
- [ ] `pwquality`
- [ ] **Só audita — não altera nada**

Requisitos comuns (6 pts):
- [ ] `set -euo pipefail` logo após o shebang
- [ ] Mínimo **5 funções**, nenhuma lógica solta no corpo
- [ ] `getopts` ou `case`; `-h` e `--help` obrigatórios
- [ ] Privilégio via `EUID` e dependências via `command -v`
- [ ] Log com timestamp, nível INFO/WARN/ERROR, arquivo em `/var/log/`
- [ ] Códigos de saída: `0` sucesso · `1` achado · `2` erro de uso · `3` dependência
- [ ] Idempotente
- [ ] Sem segredo no código
- [ ] `trap` para temporários criados com `mktemp`
- [ ] Passa no `shellcheck` sem erros
- [ ] Reversibilidade documentada
- [ ] Comentários e mensagens **em português**

Execução ao vivo (4 pts):
- [ ] Ensaiada, com saída real

## Entregável 05 — Cinco perguntas (5 pts)

- [ ] 3 múltipla escolha, 4 alternativas, **as 3 incorretas plausíveis**
- [ ] 2 dissertativas curtas (até 3 linhas), cobrando raciocínio
- [ ] Toda pergunta respondível **só com o que foi apresentado**
- [ ] **Gabarito comentado entregue 48h antes**

---

## Evidências obrigatórias

### `evidencias/01-sistema/`
- [ ] `cat /etc/os-release`
- [ ] `uname -r`
- [ ] `getenforce` → **Enforcing** (−10 pontos se estiver desligado)
- [ ] `sestatus`

### `evidencias/02-disco-luks-lvm/`
- [ ] `lsblk -f`
- [ ] `cryptsetup luksDump /dev/sda3`
- [ ] `pvs ; vgs ; lvs`
- [ ] `findmnt -o TARGET,SOURCE,FSTYPE,OPTIONS`
- [ ] `cat /etc/fstab` e `cat /etc/crypttab`

### `evidencias/03-ssh-firewall/`
- [ ] `sshd -T`
- [ ] `systemctl status sshd`
- [ ] `firewall-cmd --list-all`
- [ ] `ss -tulpn`
- [ ] `semanage port -l | grep ssh`
- [ ] Acesso por chave funcionando
- [ ] Tentativa bloqueada, com registro no `journald`

### `evidencias/04-script/`
- [ ] `shellcheck user-audit.sh`
- [ ] `bash user-audit.sh --help`
- [ ] Saída real de uma execução completa

> Saída em texto é preferida ao print — pode ser conferida.

---

## Repositório (4 pts)

- [ ] Repositório único, privado
- [ ] **Commits distribuídos entre todos os integrantes** (1 commit final de uma
      pessoa só não conta como trabalho em grupo)
- [ ] `USO-DE-IA.md` preenchido

---

## Antes de apresentar

- [ ] Snapshot da VM após instalação limpa
- [ ] Snapshot da VM após SSH configurado
- [ ] Passphrase do LUKS anotada fora da VM
- [ ] Backup do header LUKS guardado fora da VM
- [ ] Apresentação cronometrada em ensaio
- [ ] Execução ao vivo do script testada na máquina que será usada

---

## Bônus (até +10 pts)

- [ ] Boot criptografado
- [ ] Clevis/Tang
- [ ] TPM2
- [ ] 2FA
- [ ] SFTP em chroot
- [ ] Kickstart
- [ ] OpenSCAP
