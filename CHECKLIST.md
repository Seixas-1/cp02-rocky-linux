# Checklist de entrega — Grupo 2 · Rocky Linux

Data da apresentação (D-0): **__/__/____**

> **Revisão automática (17/09):** os itens abaixo foram marcados **só quando
> verificáveis no próprio repositório** (código, texto, contagem de slides,
> autoria dos commits). Itens que dependem da VM, de datas reais ou de ensaio
> continuam desmarcados. Dois pontos pedem atenção imediata do grupo:
> 1. **Todos os 8 commits até agora são de uma pessoa só** (Enzo) — fere a
>    regra de comprometimento distribuído.
> 2. **O deck está com 35 slides**, acima do teto de 30 do Entregável 02.

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

- [ ] PDF com **12 a 20 páginas** — *falta exportar; hoje só existe em Markdown*
- [x] **Mínimo 8 referências**, sendo **4 primárias** — `documento.md` tem 18 (12
      primárias); **`referencias.md` está desatualizado**, ver aviso abaixo
- [x] Cobre o recorte do grupo: RESF, *bug-for-bug*, Peridot, fim do CentOS
- [ ] Toda afirmação tem evidência correspondente em `evidencias/` — depende das
      seções 10 e 11, marcadas como **pendentes** no próprio documento

## Entregável 02 — Apresentação (15 pts)

- [ ] `.pptx` **e** PDF no repositório — `.pptx` já está em
      `docs/apresentacao/slides/`; **falta exportar o PDF**
- [ ] **20 a 30 slides** — **o deck está em 35**, acima do limite; ver aviso abaixo
- [ ] Máximo **30 minutos** (−2 pontos por minuto excedido) — plano (`falas.md`,
      15 min) cabe dentro do limite, mas **ainda não foi cronometrado em ensaio**
- [x] **Todos os integrantes apresentam** alguma parte
- [x] Slide de pergunta seguido do slide de resposta comentada

## Entregável 03 — Guia de instalação (8 pts)

- [x] `INSTALL.md` reproduzível do zero
- [x] Diagrama do particionamento — arquivo existe e está completo;
      **aprovação do professor (marco D-14) ainda não registrada**
- [ ] Prints da instalação — nenhuma imagem em `evidencias/02-disco-luks-lvm/`
- [ ] **Seção de troubleshooting com problemas reais do grupo** — tabela atual é
      genérica, com `TODO` explícito pedindo problemas reais

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
- [ ] Ensaiada, com saída real — **precisa ser feita na VM**

## Entregável 05 — Cinco perguntas (5 pts)

- [x] 3 múltipla escolha, 4 alternativas, **as 3 incorretas plausíveis**
- [x] 2 dissertativas curtas (até 3 linhas), cobrando raciocínio
- [x] Toda pergunta respondível **só com o que foi apresentado**
- [ ] **Gabarito comentado entregue 48h antes** — depende da data de apresentação
      (ainda em branco no topo deste arquivo)

---

## Evidências obrigatórias

> **Nenhum arquivo de evidência foi coletado ainda** — as quatro pastas abaixo só
> têm o `README.md` com instruções; nenhum `.txt`/print real foi commitado.
> Tudo aqui depende de acesso à VM do grupo.

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
- [ ] Tentativa bloqueada, com registro no `journald` — **screenshot solto
      (`ssh.png`) já mostra a tentativa recusada e está usado no slide 20 da
      apresentação**, mas falta o `.txt` formal do cliente e do `journalctl` nesta pasta

### `evidencias/04-script/`
- [ ] `shellcheck user-audit.sh`
- [ ] `bash user-audit.sh --help`
- [ ] Saída real de uma execução completa

> Saída em texto é preferida ao print — pode ser conferida.

---

## Repositório (4 pts)

- [x] Repositório único, privado
- [ ] **Commits distribuídos entre todos os integrantes** — **todos os 8 commits
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
