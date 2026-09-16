# Entregável 05 — As cinco perguntas para a turma

**Vale 5 pontos.** 3 de múltipla escolha (4 alternativas, as 3 incorretas
**plausíveis**) + 2 dissertativas curtas (respondíveis em até 3 linhas, cobrando
**raciocínio, não memorização de comando**).

> **Gabarito comentado entregue ao professor com 48 horas de antecedência.**
> Toda pergunta deve ser respondível apenas com o que o grupo apresentou —
> pergunta sobre conteúdo não apresentado é anulada.

---

> **Rascunho.** Revisar depois que os slides estiverem fechados: confirmar que
> cada resposta está coberta pelos blocos 1 a 5 do roteiro.

---

## Questão 1 — múltipla escolha

No esquema adotado, `/boot` fica **fora** do container LUKS. Qual é o risco
residual que essa decisão introduz?

- **a)** Os dados do usuário em `/home` ficam legíveis por quem tiver acesso
  físico ao disco.
- **b)** Um atacante com acesso físico pode adulterar o kernel ou o initramfs e
  implantar um capturador da passphrase.
- **c)** O sistema não consegue montar os volumes lógicos sem a passphrase
  digitada duas vezes.
- **d)** A partição `/boot` fica sujeita a corrupção porque o XFS não suporta
  journaling fora do LVM.

**Gabarito: b.**

**Comentário:** o GRUB precisa ler o kernel e o initramfs antes de existir
qualquer chave — a chave só é derivada depois que a passphrase é digitada, e
isso acontece a partir do initramfs. Como consequência, o conteúdo de `/boot`
não está protegido contra adulteração (*evil maid attack*). A criptografia
protege dados **em repouso** contra roubo e descarte de disco; não protege
contra modificação do que ficou fora do container.

Por que as outras são plausíveis mas erradas: **(a)** `/home` está dentro do
LUKS, justamente protegido; **(c)** a passphrase é pedida uma única vez, porque
o VG inteiro está dentro de um único container; **(d)** o XFS faz journaling
normalmente em `/boot`, e isso não tem relação com o LVM.

---

## Questão 2 — múltipla escolha

O grupo montou **LVM sobre LUKS** (o volume group inteiro dentro de um único
container criptografado), e não LUKS sobre LVM. Qual é a principal consequência
prática dessa escolha?

- **a)** Cada volume lógico pode ter sua própria passphrase, aumentando a
  granularidade do controle de acesso.
- **b)** O desempenho de escrita melhora porque a criptografia passa a ser
  aplicada por volume, e não no disco inteiro.
- **c)** É pedida uma única passphrase no boot e todo volume lógico criado depois
  já nasce criptografado.
- **d)** O `/boot` também passa a ser criptografado, eliminando a necessidade de
  Secure Boot.

**Gabarito: c.**

**Comentário:** a criptografia é propriedade do *physical volume*, não de cada
volume lógico. Um único container LUKS abriga o VG inteiro: uma passphrase é
pedida no boot, e criar um `lv_dados` amanhã não exige nenhuma etapa extra de
criptografia — ele herda a proteção. A alternativa **(a)** descreve exatamente o
arranjo inverso (LUKS sobre LVM), que exigiria um container e uma passphrase por
volume. **(b)** inverte a lógica: não há ganho de desempenho nesse arranjo.
**(d)** é falsa — `/boot` continua fora do container.

---

## Questão 3 — múltipla escolha

Por que o esquema de particionamento reserva ~9 GiB **sem alocar** no volume
group `vg_sistema`?

- **a)** Porque o LUKS2 exige espaço não alocado para armazenar o header e as
  chaves de slot.
- **b)** Porque snapshots de LVM são copy-on-write e precisam de extents livres,
  e porque sem folga não há como estender a quente um volume que encheu.
- **c)** Porque o XFS reserva automaticamente 15% do volume group para
  metadados.
- **d)** Porque o espaço livre é necessário para o `vgextend` reconhecer o
  segundo disco de 20 GB.

**Gabarito: b.**

**Comentário:** um snapshot de LVM guarda os blocos originais conforme eles são
sobrescritos, e isso exige extents livres no VG. Sem folga o grupo perde as duas
operações de socorro: tirar snapshot antes de uma mudança arriscada e estender a
quente um volume que encheu. VG a 100% não é otimização, é problema.

Por que as outras são plausíveis mas erradas: **(a)** o header do LUKS2 fica na
própria partição `sda3`, antes do PV; **(c)** o XFS reserva metadados dentro do
seu próprio sistema de arquivos, não no VG; **(d)** o `vgextend` adiciona
capacidade nova, não consome espaço livre pré-existente.

---

## Questão 4 — dissertativa curta

Aplicar `noexec` em `/var` bloqueia um vetor real de ataque, mas quebra runtimes
de container. Explique, em até três linhas, por que **documentar o conflito e a
decisão** é tecnicamente mais defensável do que simplesmente aplicar a opção
porque ela consta de uma baseline de segurança.

**Resposta esperada:** porque um controle de segurança que quebra o serviço
acaba sendo removido às pressas, sem registro, e o sistema fica pior do que se o
controle nunca tivesse sido aplicado. Documentar mostra que o risco foi avaliado
contra o impacto operacional e que existe uma decisão consciente — com dono,
justificativa e possibilidade de revisão — em vez de uma cópia de baseline que
ninguém testou.

**O que valorizar na correção:** a resposta precisa articular o **trade-off**
entre controle e disponibilidade. Resposta que apenas repete "porque o professor
pediu" ou lista as opções de montagem não pontua.

---

## Questão 5 — dissertativa curta

O `user-audit.sh` foi escrito para **somente auditar**, sem corrigir nada — ao
contrário do script do Grupo 1, que tem modo `--apply`. Explique, em até três
linhas, uma razão técnica pela qual essa restrição faz sentido especificamente
para uma ferramenta que mexe com **contas e regras de sudo**.

**Resposta esperada:** uma correção automática errada em contas ou em sudoers
pode remover o próprio caminho de acesso administrativo ao sistema — bloquear a
conta usada para administrar, ou invalidar a sintaxe do sudoers — e o operador
descobre isso quando já não tem como entrar para desfazer. Separar diagnóstico de
correção mantém a decisão com quem tem o contexto.

**O que valorizar na correção:** a resposta precisa identificar o **risco de
perda do próprio acesso** ou o risco de alteração irreversível sem supervisão.
Aceitar também a formulação equivalente à regra de ouro do SSH (validar em
sessão paralela antes de aplicar). Resposta genérica sobre "é mais seguro" sem
explicar o mecanismo não pontua.

---

# Perguntas extras (Q6–Q10) — apresentadas por João Iudi e Luana Godoy

> Mesmo critério das anteriores: respondíveis apenas com o conteúdo dos blocos 1
> a 5, com as alternativas incorretas plausíveis.

## Questão 6 — múltipla escolha

A RESF adota a regra de que **nenhuma empresa** pode ocupar mais de um terço do
conselho. Que problema concreto essa regra busca evitar?

- **a)** Que o projeto perca a compatibilidade binária com o RHEL.
- **b)** Que uma única empresa decida sozinha o rumo do projeto — foi o que
  encerrou o CentOS Linux.
- **c)** Que faltem recursos financeiros para manter o suporte de 10 anos.
- **d)** Que o Peridot deixe de ser um build system auditável.

**Gabarito: b.**

**Comentário:** a governança de fundação é a resposta direta ao caso CentOS, em
que uma empresa inverteu o modelo sozinha. As outras confundem governança com
compatibilidade **(a)**, custo **(c)** e ferramenta de build **(d)**.

---

## Questão 7 — múltipla escolha

O Rocky busca **bug-for-bug compatibility** com o RHEL. O que isso significa na
prática?

- **a)** O Rocky corrige, antes do RHEL, os bugs que encontra.
- **b)** O Rocky é apenas *parecido* com o RHEL, com pacotes equivalentes.
- **c)** Se o RHEL tem um bug, o Rocky reproduz o mesmo comportamento — para
  garantir 100% de paridade de ABI/API.
- **d)** O Rocky recebe as mudanças antes do RHEL, como vitrine de testes.

**Gabarito: c.**

**Comentário:** a meta é ser idêntico, não melhor nem parecido — assim software
certificado para RHEL roda igual. A alternativa **(d)** descreve o CentOS Stream
(upstream), o oposto do papel do Rocky.

---

## Questão 8 — múltipla escolha

Ao trocar a porta padrão do SSH, por que **só** liberar a nova porta no
`firewalld` não basta no Rocky?

- **a)** Porque o SELinux, em enforcing, bloqueia o sshd de escutar numa porta
  sem o rótulo correto — é preciso registrá-la com `semanage port`.
- **b)** Porque o `firewalld` só aceita portas registradas no `/etc/services`.
- **c)** Porque a nova porta precisa também ser adicionada ao grupo
  `AllowGroups`.
- **d)** Porque o `sshd` exige reinicialização completa da VM para trocar de
  porta.

**Gabarito: a.**

**Comentário:** no Rocky o SELinux vem em enforcing; sem o rótulo da porta o
serviço não sobe nela. **(c)** mistura porta com controle de usuários; **(b)** e
**(d)** são plausíveis, mas falsas.

---

## Questão 9 — dissertativa curta

Por que a regra de sempre rodar `sshd -t` (e testar numa **sessão paralela**)
antes de recarregar a configuração do SSH é especialmente importante num servidor
**remoto**?

**Resposta esperada:** porque um erro de sintaxe ou uma regra restritiva demais
só se manifesta ao recarregar, e num servidor remoto o próprio administrador pode
ser barrado — perdendo o único caminho de acesso para desfazer. Validar antes e
manter uma sessão aberta em paralelo garante uma rota de volta.

**O que valorizar na correção:** identificar o risco de **se trancar para fora**.
Resposta genérica ("é mais seguro") não pontua.

---

## Questão 10 — dissertativa curta

Um administrador com carga sem SLA contratual pergunta se deve pagar a subscrição
do RHEL ou usar o Rocky. Com base no que foi apresentado, justifique a
recomendação em até três linhas.

**Resposta esperada:** para essa carga o Rocky entrega o **mesmo binário**, com
10 anos de suporte e certificações RHEL válidas, sem custo de licença; o RHEL
pago só se justifica quando há necessidade de suporte comercial direto, patch de
kernel sem reboot (kpatch) ou SLA. Logo, recomenda-se **Rocky**.

**O que valorizar na correção:** condicionar a escolha ao critério de
**suporte/SLA**, não a "ser de graça".

---

## Controle de entrega

- [ ] Um slide com a pergunta, o slide seguinte com a resposta comentada
- [ ] Todas as respostas cobertas pelos blocos 1 a 5 do roteiro
- [ ] As 3 alternativas incorretas de cada questão são plausíveis
- [ ] Gabarito comentado entregue ao professor em **__/__/____** (48h antes)
