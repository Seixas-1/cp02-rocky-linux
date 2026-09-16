# Falas da apresentação — versão condensada (15 min)

Roteiro de fala por bloco, casado com os slides da apresentação. Registro falado,
em primeira pessoa. As deixas `[AÇÃO]` marcam demonstrações, vídeos e trocas de
slide. Divisão de tempo e responsáveis seguem o [roteiro](roteiro.md).

> Versão enxuta de 15 min. Para os pontos obrigatórios completos de cada bloco,
> ver `roteiro.md`.

---

## Bloco 1 — Enzo Seixas · ~2 min · slides 1–7

**[SLIDE 1]** "Boa noite, somos o Grupo 2 e nosso trabalho é sobre o **Rocky
Linux**. Eu abro com o contexto e depois cada colega assume uma parte prática."

**[SLIDES 4–5]** "O Rocky é mantido pela **RESF**, uma **fundação**, não uma
empresa — com a regra de que ninguém ocupa mais de um terço do conselho. Isso é
resposta direta ao que matou o CentOS: em 2020 a Red Hat virou o CentOS de
**downstream estável pra upstream de testes**, e antecipou o fim do suporte de
2029 pra 2021. O Rocky nasceu pra retomar aquele papel de clone estável do RHEL."

**[SLIDES 6–7]** "O conceito-chave é **bug-for-bug**: o Rocky não é *parecido*, é
**idêntico** ao RHEL — 100% de paridade, e o build é auditável via **Peridot**.
Na prática: 10 anos de suporte, sem custo, certificações RHEL valendo. Só vale o
RHEL pago quando você precisa de suporte comercial ou SLA. Passo pro João Pedro."

---

## Bloco 2 — João Pedro Ribeiro · ~2,5 min · slides 8–12

**[SLIDE 9]** "Tudo foi feito numa **VM do grupo, em rede isolada**. Este é o
ambiente. **[AÇÃO: apontar specs e os dois discos]**"

**[SLIDES 10–11]** "Usamos **LVM sobre LUKS**: um único container criptografado
com o grupo de volumes inteiro dentro. Vantagem: **uma senha só no boot**, e todo
volume novo já nasce criptografado. Duas decisões que a banca cobra: o **`/boot`
fica fora da cripto** — porque o GRUB precisa ler o kernel antes de qualquer
chave existir, e esse é o risco residual assumido; e deixamos **~9 GB livres de
propósito**, porque sem folga não dá pra tirar snapshot nem socorrer um volume
cheio."

**[SLIDE 12]** "E as **opções de montagem**: `noexec`, `nosuid` e `nodev` em
`/tmp`, `/home` e `/var/log` — cada uma bloqueia um vetor clássico de
escalonamento de privilégio."

---

## Bloco 3 — João Pedro Ribeiro · ~3,5 min · slides 13–17

**[SLIDES 14–15]** "Pra não arriscar, gravei a instalação em **vídeo
acelerado**. **[AÇÃO: play]** Quatro pontos críticos: **UEFI** (nunca BIOS),
**particionamento manual**, **marcar 'Encrypt'** no `sda3`, e **não alocar 100%
do VG**."

**[SLIDE 16]** "As provas: **[AÇÃO: mostrar prints]** `lsblk -f` com
`crypto_LUKS`, `luksDump` confirmando LUKS2, `pvs/vgs/lvs` e `findmnt` com as
opções de montagem."

**[SLIDE 17]** "E a vantagem do LVM: **crescer sem downtime**. Adicionei o 2º
disco com `pvcreate` + `vgextend` — já nasce criptografado — e cresci o volume e
o XFS a quente com `lvextend -r`, sem desmontar nada. Passo pro Guilherme."

---

## Bloco 4 — Guilherme Benjamin · ~3 min · slides 18–21

**[SLIDE 19]** "Endureci o SSH em camadas: **sem root e sem senha** — só **chave
ed25519** e só quem está no grupo (`AllowGroups`); **porta trocada** com o rótulo
SELinux via `semanage port` e liberação no `firewalld`; e sempre validar com
`sshd -t` antes do reload."

**[SLIDE 20]** "Demonstrando: **[AÇÃO: `sshd -T`]** config efetiva. **[AÇÃO:
conectar por chave]** funciona. **[AÇÃO: tentativa por senha]** bloqueada — e
**[AÇÃO: `journalctl`]** o bloqueio fica registrado."

**[SLIDE 21]** "Evidências: `firewall-cmd --list-all` e `semanage port -l | grep
ssh`. Regra de ouro: testar em sessão paralela antes de fechar a atual. Passo pro
Pedro."

---

## Bloco 5 — Pedro Rossi · ~2,5 min · slides 22–25

**[SLIDES 23–24]** "Fiz o `user-audit.sh`: **blocos independentes** — UID 0
duplicado, senha vazia, conta de sistema com shell, envelhecimento de senha,
contas inativas, `NOPASSWD` no sudoers e `pwquality`. Saída padronizada com
`ok/alerta/falha` e relatório em arquivo. E o princípio: é **somente leitura** —
audita e relata, **nunca corrige sozinho**. Isso foi decisão de projeto, não
limitação."

**[SLIDE 25]** "Rodando ao vivo: **[AÇÃO: executar o script]** vejam os alertas e
o relatório. **[AÇÃO: `shellcheck`]** limpo. Passo pro João Iudi e a Luana, com
as perguntas."

---

## Bloco 6 — João Iudi e Luana Godoy · ~1,5 min · perguntas + slide 26

> **João Iudi:** "Pra fechar, algumas perguntas rápidas pra fixar. Pergunta num
> slide, resposta comentada no seguinte." **[AÇÃO: aplicar as perguntas de
> `perguntas-gabarito.md`]**
>
> **Luana:** "Recapitulando: Rocky = downstream estável do RHEL sob fundação;
> instalação em LVM sobre LUKS; SSH só por chave; e script de auditoria
> somente-leitura."
>
> **[SLIDE 26]** **João Iudi:** "Obrigado pela atenção! Perguntas?"

---

## Cronometragem

- Os blocos 3 (instalação) e 4 (SSH) dependem de vídeo/demo — cronometrar **com o
  vídeo rodando** no ensaio, porque é onde o tempo estoura.
- Desconto de **−2 pontos por minuto excedido**.
