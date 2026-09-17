# Checklist de entrega — Grupo 2 · Rocky Linux

Data da apresentação (D-0): **__/__/____**

> **Revisão automática (17/09, atualizada):** os itens abaixo foram marcados
> **só quando verificáveis no próprio repositório** (código, texto, contagem de
> slides, autoria dos commits, conteúdo real do `.pptx`). O grupo já trocou o
> deck por uma versão com prints e vídeo reais embutidos — ver notas por
> entregável. Três pontos pedem atenção imediata:
> 1. **Todos os commits até agora são de uma pessoa só** (Enzo) — fere a
>    regra de comprometimento distribuído.
> 2. **O deck está com 37 slides**, acima do teto de 30 do Entregável 02 — por
>    orientação do grupo, isso **fica para ajuste na semana da apresentação** e
>    não foi mexido agora.
> 3. **O print do script no slide 25 mostra um script diferente do que está
>    commitado** (`audit.sh`/`auditoria.sh`, com menu interativo e `--auto`) —
>    o repositório tem `user-audit.sh`, com outras flags e sem modo interativo.
>    Precisa confirmar qual é a versão final antes de apresentar.

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

- [ ] PDF com **12 a 20 páginas** — **PDF gerado** em `docs/pesquisa/documento.pdf`,
      mas saiu com **10 páginas** (2 abaixo do mínimo); tende a crescer quando as
      seções 10 e 11 (hoje "pendentes") forem escritas com a parte prática
- [x] **Mínimo 8 referências**, sendo **4 primárias** — `documento.md` tem 18 (12
      primárias); **`referencias.md` está desatualizado**, ver aviso abaixo
- [x] Cobre o recorte do grupo: RESF, *bug-for-bug*, Peridot, fim do CentOS
- [ ] Toda afirmação tem evidência correspondente em `evidencias/` — depende das
      seções 10 e 11, marcadas como **pendentes** no próprio documento

## Entregável 02 — Apresentação (15 pts)

> **Por pedido do grupo, esta seção fica como está — será revista na semana da
> apresentação.** Só a contagem de slides abaixo foi atualizada para refletir
> a versão atual do arquivo.

- [ ] `.pptx` **e** PDF no repositório — `.pptx` já está em
      `docs/apresentacao/slides/`; **falta exportar o PDF**
- [ ] **20 a 30 slides** — **o deck está em 37**, acima do limite; ver aviso abaixo
- [ ] Máximo **30 minutos** (−2 pontos por minuto excedido) — plano (`falas.md`,
      15 min) cabe dentro do limite, mas **ainda não foi cronometrado em ensaio**
- [x] **Todos os integrantes apresentam** alguma parte
- [x] Slide de pergunta seguido do slide de resposta comentada

## Entregável 03 — Guia de instalação (8 pts)

> **Instalação realizada com sucesso, segundo o grupo.** As evidências visuais
> vivem no `.pptx` (`docs/apresentacao/slides/`), não em `evidencias/`:
> diagrama real no slide 9, vídeo da instalação com print do VirtualBox
> (specs da VM: 4096 MB, 2 vCPUs, disco de 60,43 GB) no slide 15.

- [x] `INSTALL.md` reproduzível do zero
- [x] Diagrama do particionamento — arquivo existe e está completo, e o mesmo
      diagrama está no slide 9 do `.pptx`;
      **aprovação formal do professor (marco D-14) ainda não registrada**
- [x] Prints da instalação — **cobertos pelo vídeo + print no slide 15** do
      `.pptx` (não há cópia separada em `evidencias/02-disco-luks-lvm/`, mas o
      grupo optou por manter as evidências visuais só na apresentação)
- [ ] **Seção de troubleshooting com problemas reais do grupo** — tabela do
      `INSTALL.md` ainda é genérica, com `TODO` explícito pedindo problemas
      reais; nenhum incidente real foi relatado a mim para eu registrar aqui —
      quem passou por um perrengue durante a instalação, escreve essa linha

## Entregável 04 — Script `user-audit.sh` (20 pts)

Requisitos do grupo (10 pts) — o script detecta:
- [x] UID 0 duplicado
- [x] Senha vazia
- [x] Conta de sistema com shell válido
- [x] Envelhecimento de senha via `chage`
- [x] Contas paradas há 90 dias
- [x] `NOPASSWD` no sudoers
- [x] `pwquality`
- [x] **Só audita — não altera nada**

Requisitos comuns (6 pts):
- [x] `set -euo pipefail` logo após o shebang
- [x] Mínimo **5 funções**, nenhuma lógica solta no corpo
- [x] `getopts` ou `case`; `-h` e `--help` obrigatórios
- [x] Privilégio via `EUID` e dependências via `command -v`
- [x] Log com timestamp, nível INFO/WARN/ERROR, arquivo em `/var/log/`
- [x] Códigos de saída: `0` sucesso · `1` achado · `2` erro de uso · `3` dependência
- [x] Idempotente
- [x] Sem segredo no código
- [x] `trap` para temporários criados com `mktemp`
- [ ] Passa no `shellcheck` sem erros — **não verificável fora da VM**; sem
      `shellcheck` instalado neste ambiente e sem `evidencias/04-script/shellcheck.txt`
- [x] Reversibilidade documentada — cada achado tem uma linha "Correção manual"
- [x] Comentários e mensagens **em português**

Execução ao vivo (4 pts):
- [ ] Ensaiada, com saída real — o slide 25 já tem um **print real de execução**
      (`--help`), mas ⚠️ **é de um script diferente do que está no repositório**:
      o print mostra `./audit.sh` / `auditoria.sh`, com **menu interativo** e
      flag `--auto` ("roda as 7 verificações e sai, use no cron"); o
      `scripts/user-audit.sh` commitado não tem menu interativo nem `--auto` —
      usa `--dias`, `--saida`, `--silencioso`, `--sem-cor`. **Confirmar com o
      Pedro qual versão é a definitiva** antes de apresentar: ou o print é de
      um protótipo anterior e precisa ser trocado, ou o script commitado está
      desatualizado em relação ao que foi de fato testado

## Entregável 05 — Cinco perguntas (5 pts)

- [x] 3 múltipla escolha, 4 alternativas, **as 3 incorretas plausíveis**
- [x] 2 dissertativas curtas (até 3 linhas), cobrando raciocínio
- [x] Toda pergunta respondível **só com o que foi apresentado**
- [ ] **Gabarito comentado entregue 48h antes** — depende da data de apresentação
      (ainda em branco no topo deste arquivo)

---

## Evidências obrigatórias

> **Decisão do grupo: as evidências vivem no `.pptx`, não nesta pasta.** As
> quatro pastas abaixo continuam só com o `README.md` de instruções — nenhum
> `.txt` foi commitado aqui, de propósito. Os checkboxes abaixo refletem o que
> **dá para ver na apresentação**, não o que está em `evidencias/`. Ainda assim,
> nem todo comando pedido pela rubrica aparece claramente num print ou vídeo —
> o que segue marcado é só o que eu consegui confirmar pelas imagens do deck.

### `evidencias/01-sistema/`
- [ ] `cat /etc/os-release`
- [ ] `uname -r`
- [ ] `getenforce` → **Enforcing** (−10 pontos se estiver desligado)
- [ ] `sestatus`

> Nenhum desses aparece num slide dedicado — só as specs da VM (slide 15, print
> do VirtualBox). Vale conferir se algum desses comandos aparece dentro do
> vídeo da instalação; se não aparecer, ainda falta.

### `evidencias/02-disco-luks-lvm/`
- [ ] `lsblk -f`
- [ ] `cryptsetup luksDump /dev/sda3`
- [ ] `pvs ; vgs ; lvs`
- [ ] `findmnt -o TARGET,SOURCE,FSTYPE,OPTIONS`
- [ ] `cat /etc/fstab` e `cat /etc/crypttab`

> O slide "EVIDÊNCIAS" (16) do `.pptx` **ainda está vazio** — nenhum desses
> comandos tem print dedicado hoje. O diagrama (slide 9) e o vídeo (slide 15)
> cobrem a explicação, não a saída desses comandos específicos.

### `evidencias/03-ssh-firewall/`
- [ ] `sshd -T`
- [ ] `systemctl status sshd`
- [ ] `firewall-cmd --list-all`
- [ ] `ss -tulpn`
- [ ] `semanage port -l | grep ssh`
- [ ] Acesso por chave funcionando
- [x] Tentativa bloqueada, com registro no `journald` — **print real** (`ssh.png`)
      agora está no slide de "Evidência" do bloco SSH do `.pptx`, mostrando
      `Permission denied (publickey,...)`; **falta o `.txt` do `journalctl`**
      correspondente para fechar o item por completo

### `evidencias/04-script/`
- [ ] `shellcheck user-audit.sh`
- [x] `bash user-audit.sh --help` — **há um print de `--help` no slide 25**, mas
      ver o aviso sobre a divergência de script no Entregável 04 acima
- [ ] Saída real de uma execução completa

> Saída em texto é preferida ao print — pode ser conferida. Como o grupo optou
> por prints, fica mais difícil para o professor copiar/conferir comandos; se
> der, vale complementar com os `.txt` mesmo mantendo os prints nos slides.

---

## Repositório (4 pts)

- [x] Repositório único, privado
- [ ] **Commits distribuídos entre todos os integrantes** — **todos os commits
      até agora são do Enzo** (mesmo e-mail, nomes diferentes); os outros cinco
      integrantes ainda não têm nenhum commit próprio — ver aviso abaixo
- [x] `USO-DE-IA.md` preenchido

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
