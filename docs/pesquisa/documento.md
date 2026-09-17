# Rocky Linux: da descontinuação do CentOS a uma fundação com controle comunitário

**CP 02 — Ambiente Linux (RHEL)**
FIAP — Sistemas Operacionais Linux / Cibersegurança
Grupo 2 — Rocky Linux

| Integrante | RM |
|---|---|
| Enzo Seixas | 572294 |
| João Pedro Ribeiro | 570090 |
| Guilherme Benjamim | 573724 |
| Pedro Rossi | 571590 |
| João Iudi | 573667 |
| Luana Godoy | 562776 |

---

## Sumário

1. Introdução
2. O ecossistema Red Hat e por que ele importa
3. O fim do CentOS
4. O nascimento do Rocky Linux e a RESF
5. Compatibilidade bug-for-bug
6. Peridot: o build system como argumento de resiliência
7. A mudança de 2023 e o teste do modelo
8. Ciclo de vida e suporte
9. Quando escolher Rocky Linux
10. Aplicação prática: o ambiente construído pelo grupo
11. Conclusão
12. Referências

---

## 1. Introdução

Este documento acompanha o trabalho prático do Grupo 2, que instalou e endureceu
um servidor Rocky Linux com LVM sobre LUKS, configurou o serviço OpenSSH fora dos
padrões de fábrica e desenvolveu um script de auditoria de contas, senhas e
privilégios.

O recorte de pesquisa atribuído ao grupo trata da distribuição em si: a Rocky
Enterprise Software Foundation (RESF) que a mantém, o conceito de compatibilidade
*bug-for-bug* com o Red Hat Enterprise Linux, o sistema de build Peridot, e o
episódio que deu origem ao projeto — a descontinuação do CentOS Linux.

Esses quatro pontos não são independentes. O fim do CentOS produziu o Rocky; a
forma como o CentOS terminou determinou a estrutura jurídica escolhida para a
RESF; a promessa de compatibilidade define o que o projeto precisa entregar; e o
Peridot é a resposta técnica à pergunta que todo administrador passou a fazer
depois de 2020: o que garante que isso não vai acontecer de novo?

---

## 2. O ecossistema Red Hat e por que ele importa

Bancos, operadoras de telecomunicações, órgãos de governo e grandes varejistas
operam sobre Red Hat Enterprise Linux e seus derivados. A razão não é técnica no
sentido estrito — é contratual e de ciclo de vida. Um fornecedor de software
corporativo homologa seu produto contra uma lista curta de sistemas operacionais,
e o RHEL costuma estar nela.

Para quem vem do Debian ou do Ubuntu, a mudança de ecossistema é concreta:

| Aspecto | Debian / Ubuntu | RHEL e derivados |
|---|---|---|
| Gerenciador de pacotes | `apt` / `dpkg` | `dnf` / `rpm` |
| Formato de pacote | `.deb` | `.rpm` |
| Firewall padrão | `ufw` ou nftables direto | `firewalld` |
| Instalador | debian-installer | Anaconda |
| Controle de acesso obrigatório | AppArmor; SELinux não vem habilitado | **SELinux em `enforcing` por padrão** |

O último item é o mais relevante para este trabalho. O SELinux não é um detalhe
de configuração: é um mecanismo de controle de acesso obrigatório que rotula cada
processo e cada arquivo, e nega operações que fogem da política mesmo quando as
permissões tradicionais do Unix as permitiriam.

Um administrador acostumado a Debian, ao mover o serviço SSH para uma porta não
padrão, descobre que o serviço simplesmente não sobe — porque a porta nova não
carrega o rótulo `ssh_port_t`. O comportamento é tratado na seção 10 e no guia de
instalação do grupo.

---

## 3. O fim do CentOS

### 3.1 O que o CentOS Linux era

O CentOS Linux era um *rebuild* binário do RHEL. A Red Hat publica o código-fonte
de sua distribuição, como exige a GPL, e o projeto CentOS recompilava esse código
removendo marcas registradas, entregando um sistema funcionalmente idêntico ao
RHEL e gratuito.

A propriedade que fazia dele o que era chama-se **downstream**: o CentOS Linux
vinha *depois* do RHEL. Cada versão correspondia a uma versão do RHEL já lançada,
já testada e já em produção em clientes pagantes. Quem instalava CentOS obtinha a
estabilidade do RHEL sem o contrato de suporte.

### 3.2 O anúncio de dezembro de 2020

Em **8 de dezembro de 2020**, Rich Bowen publicou no blog oficial do projeto o
texto *CentOS Project shifts focus to CentOS Stream* [P1]. O anúncio determinava
que o CentOS Linux 8, enquanto rebuild do RHEL 8, **terminaria ao final de 2021**,
e que o foco do projeto passaria integralmente ao CentOS Stream.

O impacto estava no encurtamento. O CentOS Linux 8 tinha suporte previsto até
**2029**, alinhado ao ciclo de dez anos do RHEL 8 [S1][S4]. A mudança reduziu essa
janela para **dezembro de 2021** — de nove anos restantes para pouco mais de um.
Organizações que haviam padronizado sobre CentOS 8 planejando uma década de
suporte passaram a ter doze meses para migrar.

O CentOS Linux 7 foi preservado até o fim do ciclo do RHEL 7 [P1], encerrado em
**30 de junho de 2024** [S4].

### 3.3 A inversão de posição

A questão central não é o CentOS Stream ser pior — é ele ocupar posição diferente
na cadeia:

```
ANTES DE 2020
   Fedora  -->  RHEL  -->  CentOS Linux
 (upstream)   (estavel)   (downstream, rebuild)

DEPOIS DE 2020
   Fedora  -->  CentOS Stream  -->  RHEL
 (upstream)  (preview continuo)   (estavel)
```

O CentOS Stream é uma *rolling preview* da próxima versão menor do RHEL: o código
entra ali **antes** de chegar ao RHEL. É um ambiente legítimo e útil — permite à
comunidade influenciar o RHEL antes do congelamento —, mas entrega o oposto do
que o CentOS Linux entregava. Quem escolhia CentOS por querer estabilidade
downstream comprovada perdeu exatamente essa propriedade.

Foi esse vácuo que os projetos sucessores se propuseram a preencher.

---

## 4. O nascimento do Rocky Linux e a RESF

### 4.1 A reação imediata

A resposta veio de **Gregory Kurtzer**, fundador original do projeto CentOS, que
anunciou a criação de um projeto para alcançar os objetivos originais do CentOS
[P7].

O nome é uma homenagem. Kurtzer explicou a escolha referindo-se ao cofundador do
CentOS, Rocky McGaugh, já falecido, que nunca chegou a ver o sucesso que o projeto
alcançaria [S5]. A adesão foi imediata: em 12 de dezembro de 2020, poucos dias
após o anúncio, o repositório do Rocky Linux era o mais popular do GitHub [S5].

A primeira versão de disponibilidade geral, **Rocky Linux 8.4**, foi publicada em
**21 de junho de 2021** [P11], cerca de sete meses após o anúncio da Red Hat.

### 4.2 A RESF e a lição aprendida

Aqui está o ponto que diferencia o Rocky de um simples fork técnico. O problema do
CentOS não foi de engenharia — o CentOS Linux funcionava. O problema foi de
**governança**: o projeto havia sido absorvido pela Red Hat, e a decisão de
descontinuá-lo foi tomada por uma única empresa.

A **Rocky Enterprise Software Foundation (RESF)** é a resposta estrutural a isso.
Kurtzer registrou a fundação como uma **Delaware Public Benefit Corporation
(PBC)** [P2] — forma jurídica que obriga a organização a perseguir um benefício
público declarado, e não apenas o retorno dos acionistas.

Em **9 de novembro de 2022**, um grupo inicial de **30 membros fundadores** aprovou
o estatuto e os regimentos da RESF [P2]. Ao ratificá-los, Kurtzer transferiu
legalmente o controle da fundação para a estrutura definida nesses documentos. As
garantias relevantes [P2]:

- Todas as cadeiras do conselho são eleitas por pares, **exclusivamente por
  mérito**. Nenhuma cadeira é comprada ou vendida.
- **Nenhuma empresa pode representar mais de um terço** de qualquer conselho
  votante.
- A adesão exige apenas atuação ativa no projeto e candidatura; todos os membros
  são iguais.
- Cada projeto tem seu próprio conselho, e cada conselho de projeto tem assento no
  conselho da fundação.
- Patrocinadores principais recebem assentos consultivos **sem direito a voto**.

O princípio declarado é que o Rocky Linux nunca será controlado, comprado ou de
outra forma influenciado por uma única entidade ou indivíduo [P2].

> **Ponto para a apresentação.** A regra do terço e a separação entre patrocínio e
> voto são exatamente o mecanismo que faltava ao CentOS. Um patrocinador pode
> financiar o projeto sem poder decidir seu destino.

---

## 5. Compatibilidade bug-for-bug

### 5.1 O que a expressão significa

O Rocky Linux se declara **100% bug-for-bug compatible** com o Red Hat Enterprise
Linux [P6][P12]. A formulação é deliberadamente mais forte do que "compatível".

*Compatível* admite interpretação: o software roda, talvez com ajustes.
*Bug-for-bug* afirma que a distribuição reproduz o comportamento do RHEL
**inclusive nos defeitos**. Se uma biblioteca do RHEL 9.4 tem uma falha
específica, o Rocky 9.4 tem a mesma falha, com o mesmo comportamento observável.

### 5.2 Por que isso é requisito comercial, não curiosidade

A razão é homologação. Um SGBD comercial, um ERP, um agente de backup ou uma
solução de EDR é certificado contra o RHEL em uma versão específica. Essa
certificação tem valor contratual: define a quem o cliente recorre quando algo
quebra em produção.

Se o Rocky reproduz o RHEL bit a bit, o software homologado funciona sem nova
certificação, porque não existe diferença observável a certificar. Qualquer
divergência — mesmo uma correção de bug bem-intencionada — cria uma superfície em
que o fornecedor pode legitimamente alegar que aquele não é o ambiente homologado.

**É por isso que corrigir um bug que o RHEL tem seria, para um rebuild downstream,
quebrar a promessa.**

### 5.3 O contraste com o AlmaLinux

Em julho de 2023, o conselho da AlmaLinux OS Foundation decidiu **abandonar o
objetivo de ser 1:1 com o RHEL**, passando a mirar compatibilidade de **ABI**
(Application Binary Interface) [P9][S2].

A consequência prática é direta: o AlmaLinux deixou de estar preso à linha da
compatibilidade bug-for-bug e passou a **poder aceitar correções fora do ciclo de
lançamento da Red Hat** [P9]. Aplicações compatíveis com RHEL continuam
executando, e as atualizações de segurança seguem.

São duas filosofias defensáveis para problemas diferentes:

| | Rocky Linux | AlmaLinux (desde jul/2023) |
|---|---|---|
| Objetivo declarado | 100% bug-for-bug | Compatibilidade de ABI |
| Pode corrigir bug antes do RHEL | Não, por definição | Sim |
| Aposta principal | Previsibilidade e homologação | Agilidade de correção |
| Custo da escolha | Herda também os defeitos | Divergência observável do RHEL |

Para um ambiente com software de terceiros homologado, a rigidez do Rocky é
vantagem. Para um ambiente de aplicações próprias, a flexibilidade do AlmaLinux
pode valer mais.

---

## 6. Peridot: o build system como argumento de resiliência

### 6.1 O que é

**Peridot** é o sistema de build *cloud-native* voltado à construção de pacotes RPM
que a equipe do Rocky desenvolveu e liberou como software livre [P3]. Todo o Rocky
Linux é construído com ele, e o código está publicamente disponível no serviço Git
da RESF e no GitHub [P3].

Características relevantes [S3]:

- Vem pré-configurado com a localização do código-fonte e dos *patches*; a chegada
  de uma nova versão do fonte dispara a atualização.
- Paraleliza massivamente: a equipe relata a construção de mais de **2.500 pacotes
  em paralelo** para `x86_64` e `aarch64`.
- Foi projetado com a meta explícita de publicar uma nova versão do Rocky **dentro
  de uma semana** após cada lançamento do RHEL.

### 6.2 Por que um build system aberto é argumento de governança

Esta é a parte que costuma passar despercebida, e é o que conecta o Peridot ao
resto do recorte.

A promessa da RESF — de que o Rocky não pode ser descontinuado por decisão de uma
única empresa — seria retórica se a capacidade de *construir* a distribuição
estivesse concentrada em infraestrutura fechada de um único ator. Quem controla o
build controla o projeto, independentemente do que diga o estatuto.

Ao liberar o Peridot, a RESF tornou a distribuição **reconstruível por terceiros**:
qualquer pessoa ou organização pode recriar, construir, estender e manter o Rocky
Linux, ou derivar sua própria distribuição a partir dele [S3]. A garantia deixa de
depender exclusivamente de boa-fé e passa a ter suporte técnico verificável.

> **Ponto para a apresentação.** O Peridot é a resposta técnica à mesma pergunta
> que a RESF responde juridicamente. Estatuto sem build reproduzível é promessa;
> build reproduzível sem estatuto é sorte. O Rocky tem os dois.

---

## 7. A mudança de 2023 e o teste do modelo

### 7.1 O que a Red Hat fez

Em **21 de junho de 2023**, a Red Hat anunciou que deixaria de publicar os fontes
do RHEL em `git.centos.org`, tornando o **CentOS Stream o único repositório
público** de código relacionado ao RHEL. Para clientes e parceiros, os fontes
seguem disponíveis pelo Portal do Cliente [P10][S2].

Como os rebuilds dependiam justamente daquele repositório para reproduzir o RHEL
versão a versão, a mudança atingiu diretamente Rocky Linux, AlmaLinux, EuroLinux e
Oracle Linux [S2].

### 7.2 Como o Rocky respondeu

O projeto publicou o posicionamento *Keeping Open Source Open* [P4]. O conteúdo
técnico é o seguinte: o Rocky passou a obter fontes de **múltiplas origens** em vez
de uma só — CentOS Stream, pacotes *pristine* do upstream e SRPMs do próprio RHEL.
Duas vias específicas foram citadas [P4]:

- **Imagens de contêiner UBI** baseadas em RHEL, disponíveis em diversas fontes
  públicas, que permitem acesso desimpedido aos fontes.
- **Instâncias de nuvem pagas por uso**, em que qualquer pessoa pode iniciar uma
  imagem RHEL para obter o código — processo escalável via pipelines de CI.

O projeto sustenta que termos de serviço e contratos de licença que tentam impedir
clientes de exercer seus direitos sob a GPL contrariam o espírito do código aberto
[P4]. Em paralelo, a Red Hat publicou sua própria defesa da decisão [P10].

### 7.3 A leitura para este trabalho

O episódio de 2023 funcionou como teste de estresse do modelo descrito nas seções
4 e 6. Um projeto que dependesse de um único canal de fontes e de infraestrutura
de build fechada teria parado. O Rocky continuou publicando versões e segue
declarando compatibilidade bug-for-bug [P5].

Isso não elimina a dependência estrutural: o Rocky continua sendo um rebuild e,
portanto, continua dependendo de o RHEL existir e de seus fontes serem alcançáveis
por alguma via legítima. O que o episódio demonstra é que a dependência é de
**disponibilidade do código**, não de **cooperação do fornecedor** — distinção que
importa na hora de avaliar risco.

---

## 8. Ciclo de vida e suporte

O Rocky Linux acompanha o ciclo de aproximadamente dez anos do RHEL. As datas de
fim de suporte publicadas [P8][S6]:

| Versão | Fim do suporte |
|---|---|
| Rocky Linux 8 | 31 de maio de 2029 |
| Rocky Linux 9 | 31 de maio de 2032 |
| Rocky Linux 10 | suporte geral até 31 de maio de 2030; segurança até 31 de maio de 2035 |

Uma diferença operacional importante em relação ao RHEL: **o Rocky não mantém
versões menores antigas**. Assim que uma nova versão de ponto é publicada, a
anterior é imediatamente considerada encerrada, e é necessário atualizar para
continuar recebendo correções de segurança [P8]. O RHEL, por contrato, oferece
*Extended Update Support* para versões menores específicas — recurso que o Rocky
não replica.

Comparação com as demais distribuições do ecossistema:

| Distribuição | Posição | Ciclo aproximado |
|---|---|---|
| Fedora | Upstream do RHEL | cerca de 13 meses |
| CentOS Stream | Preview contínuo do RHEL | contínuo, por versão maior |
| RHEL | Estável, comercial | 10 anos |
| Rocky Linux | Downstream, rebuild | 10 anos, alinhado ao RHEL |

---

## 9. Quando escolher Rocky Linux

**Faz sentido escolher Rocky quando:**

- o requisito é compatibilidade com RHEL sem custo de subscrição;
- a organização tem equipe capaz de operar o sistema sem suporte contratado;
- o parque é grande e o custo por instância de uma subscrição seria proibitivo;
- o ambiente é de laboratório, desenvolvimento, ensino ou pesquisa;
- a preocupação com governança é real e a estrutura da RESF é um diferencial.

**Faz mais sentido o RHEL com subscrição quando:**

- existe exigência contratual de suporte com SLA definido;
- há necessidade de responsabilização jurídica sobre o fornecedor do SO;
- o ambiente depende de certificações formais que nomeiam o RHEL;
- ferramentas do ecossistema comercial — como o Red Hat Insights — fazem parte da
  operação;
- é necessário *Extended Update Support* em uma versão menor específica.

A escolha, portanto, não é técnica em primeiro lugar. Nas duas colunas o sistema é
o mesmo; o que difere é a quem se recorre quando algo quebra às três da manhã.

---

## 10. Aplicação prática: o ambiente construído pelo grupo

> **Seção pendente.** O conteúdo abaixo é a estrutura acordada; os números,
> saídas de comando e decisões concretas serão preenchidos a partir das
> evidências coletadas na máquina virtual do grupo, armazenadas em `evidencias/`.

As seções anteriores discutiram o Rocky Linux como projeto — governança,
compatibilidade, ciclo de vida. Esta seção fecha o documento no plano oposto: o
que o grupo efetivamente construiu, com as decisões de configuração tomadas e o
raciocínio de segurança por trás de cada uma. Os comandos e as saídas completas
de cada verificação estão registrados em vídeo e em capturas de tela na
apresentação do grupo (`docs/apresentacao/slides/`); o que segue aqui é a
descrição técnica dessas decisões.

### 10.1 Especificação do ambiente

O ambiente é uma máquina virtual criada no Oracle VirtualBox, rodando Rocky
Linux 9, com firmware UEFI habilitado — pré-requisito para o esquema de
particionamento adotado (seção 10.2). A configuração de hardware é 2 vCPUs e
4096 MB de memória RAM, com um disco primário de 60 GB (`/dev/sda`) usado na
instalação e um segundo disco de 20 GB (`/dev/sdb`) adicionado posteriormente
para demonstrar a extensão a quente do LVM (seção 10.6). A rede é isolada,
configurada em modo NAT, para garantir que nenhum comando de teste — em
particular as tentativas de acesso SSH da seção 10.4 — alcance qualquer
equipamento fora da VM do próprio grupo.

### 10.2 Particionamento com LVM sobre LUKS

O esquema adotado segue o diagrama em `docs/diagrama-particionamento.md`: o
disco de 60 GB é dividido em três partições. `sda1` (1 GB, FAT32) hospeda o
`/boot/efi`, exigido pelo firmware UEFI. `sda2` (1 GB, xfs) hospeda o `/boot`.
Ambas ficam fora de qualquer criptografia — decisão obrigatória, não opcional:
o GRUB precisa ler o kernel e o initramfs antes de qualquer chave existir, e é
justamente o initramfs que pede a passphrase e desbloqueia o restante do disco.
Esse é o risco residual assumido conscientemente pelo grupo: um atacante com
acesso físico ao disco pode adulterar o conteúdo de `/boot` sem precisar de
senha alguma, ainda que não consiga ler os dados do sistema em si (que estão
dentro do container criptografado).

A terceira partição, `sda3` (~58 GB), é um único container LUKS2. Dentro dele
vive o volume físico `/dev/mapper/cryptlvm`, sobre o qual está o volume group
`vg_sistema`, particionado em oito volumes lógicos: `lv_root` (15 GB, `/`),
`lv_var` (8 GB, `/var`), `lv_varlog` (5 GB, `/var/log`), `lv_vartmp` (3 GB,
`/var/tmp`), `lv_home` (10 GB, `/home`), `lv_tmp` (3 GB, `/tmp`), `lv_swap`
(4 GB) e cerca de 9 GB deliberadamente não alocados. Essa reserva não é
desperdício: sem espaço livre no volume group não há como criar um snapshot
antes de uma mudança arriscada, nem como socorrer um volume lógico que encheu
— um volume group a 100% de uso é um incidente à espera de acontecer, não uma
otimização. A escolha de colocar o volume group inteiro dentro de um único
container LUKS2 — em vez de cifrar cada volume lógico separadamente — também é
deliberada: o sistema pede a passphrase uma única vez no boot, e qualquer
volume lógico criado depois (como na extensão da seção 10.6) já nasce
criptografado por herança, sem etapa extra.

### 10.3 Opções de montagem restritivas

Cada volume lógico recebeu as opções de montagem mínimas necessárias para o seu
propósito, de modo que cada uma bloqueie um vetor de ataque específico:

| Ponto de montagem | Opções | O que a opção impede |
|---|---|---|
| `/tmp`, `/var/tmp` | `nodev, nosuid, noexec` | Executar um payload gravado em diretório mundialmente gravável — o vetor mais clássico de escalonamento de privilégio |
| `/home` | `nodev, nosuid` | Um usuário comum criar um binário SUID dentro do próprio diretório |
| `/var/log` | `nodev, nosuid, noexec` | Comprometer a integridade dos logs, ou usar a área de log como ponto de estágio de um ataque |
| `/boot`, `/var` | `nodev` (`/boot` também recebe `nosuid`) | Isola o crescimento de dados de serviço e protege a área de boot |

O ponto que exigiu mais atenção foi o `noexec` em `/var` e `/var/tmp`: essa
opção é a mais eficaz contra o vetor de escalonamento descrito acima, mas é
também a que mais frequentemente quebra software legítimo — em particular
runtimes de contêiner e o próprio `dnf`, que descompacta pacotes temporariamente
em `/var/tmp` durante atualizações. A decisão do grupo foi manter a opção e
documentar o conflito explicitamente (`docs/diagrama-particionamento.md`), em
vez de simplesmente aplicar uma baseline copiada sem testar: um controle de
segurança que quebra o serviço tende a ser removido às pressas e sem registro,
o que deixa o sistema pior do que se o controle nunca tivesse sido aplicado.

### 10.4 Endurecimento do serviço OpenSSH

O `sshd` foi movido para uma porta não padrão, com autenticação restrita a
chave pública ed25519 — `PermitRootLogin no` e `PasswordAuthentication no` —,
acesso limitado a um grupo dedicado (`AllowGroups`) e um banner de aviso legal
exibido antes de qualquer autenticação. Mover o serviço de porta expôs a mesma
interação com o SELinux antecipada na seção 2: em modo enforcing, o SELinux
bloqueia o `sshd` de escutar em uma porta sem o rótulo de tipo correto,
independentemente do que o `firewalld` permitir — foi necessário registrar a
nova porta com `semanage port` antes que o serviço voltasse a responder nela.

O grupo capturou as duas evidências exigidas pela rubrica. Na tentativa
correta — usuário autorizado, chave privada válida — o acesso é concedido
normalmente. Na tentativa incorreta — sem uma chave privada acessível — o
cliente primeiro exibe o banner de aviso legal configurado (confirmando que o
`/etc/issue.net` está de fato sendo servido antes da autenticação) e em seguida
recebe `Permission denied (publickey,gssapi-keyex,gssapi-with-mic)`: a
mensagem de erro por si só confirma que o servidor não oferece os métodos de
senha como alternativa, apenas os métodos baseados em chave — exatamente o
comportamento esperado de `PasswordAuthentication no`.

### 10.5 O script `user-audit.sh`

O `user-audit.sh` audita a base local de contas, senhas e privilégios em busca
de sete classes de desvio: UID 0 duplicado, senha vazia, conta de sistema com
shell de login válido, envelhecimento de senha fora da política (os mesmos
campos de `/etc/shadow` que o `chage` administra), contas humanas sem uso há
mais de 90 dias, diretivas `NOPASSWD` ativas em `/etc/sudoers` e
`/etc/sudoers.d`, e conformidade da política de complexidade de senha
(`pwquality`). A decisão de projeto mais relevante do script é que ele apenas
audita e não corrige nada: uma correção automática equivocada em contas ou em
regras de `sudo` pode remover o próprio caminho de acesso administrativo ao
sistema — bloquear a conta usada para administrar, ou invalidar a sintaxe do
`sudoers` — e o operador só descobre isso quando já não tem mais como entrar
para desfazer. Cada achado do relatório vem acompanhado da linha de correção
manual correspondente, deixando a decisão de aplicá-la com quem tem o contexto
completo do sistema.

### 10.6 Ciclo de vida do LVM

Para demonstrar que o esquema de disco escolhido comporta crescimento sem
indisponibilidade, o grupo estendeu o `vg_sistema` a quente com o segundo disco
de 20 GB: `pvcreate` transforma o disco em um novo volume físico, `vgextend` o
incorpora ao volume group existente — herdando a criptografia do container
LUKS2 automaticamente, sem nenhuma configuração adicional —, e `lvextend -r`
amplia o volume lógico e o sistema de arquivos XFS em uma única operação, com o
sistema no ar e sem desmontar nada. A reserva de espaço livre descrita na seção
10.2 é o que torna essa operação segura: antes de qualquer extensão, é possível
tirar um snapshot do estado atual, algo impossível em um volume group já
saturado. Vale registrar uma limitação assumida: o XFS não suporta redução
(shrink) — o dimensionamento dos volumes lógicos precisa ser pensado com folga
desde a fase de diagrama, porque ele só pode crescer depois.

---

## 11. Conclusão

> **Seção pendente.** Será escrita após a conclusão da parte prática.

O fio condutor deste documento é que o fim do CentOS Linux não foi uma falha
técnica, e sim uma falha de governança: uma única empresa mudou unilateralmente
o papel de um projeto do qual milhares de organizações dependiam, sem aviso
prévio proporcional ao impacto. É por isso que a resposta do Rocky Linux foi
tanto jurídica quanto técnica. No plano jurídico, a RESF existe como fundação
sem fins lucrativos com uma regra explícita contra concentração de poder —
nenhuma empresa pode ocupar mais de um terço do conselho — precisamente para
que o episódio do CentOS não se repita sob outro nome. No plano técnico, a
compatibilidade bug-for-bug é uma restrição autoimposta com custo real: herdar
os defeitos do RHEL em vez de corrigi-los, em troca de um benefício comercial
concreto, que é preservar a homologação binária de todo software já
certificado para a plataforma.

O Peridot e a estrutura de governança da RESF endereçam a mesma pergunta — "o
que acontece se o modelo atual falhar de novo?" — por caminhos diferentes: um
técnico (um sistema de build auditável, que qualquer um pode replicar sem
depender da infraestrutura de uma única organização) e outro institucional
(uma regra estatutária de distribuição de poder). O episódio de junho de 2023,
em que a Red Hat restringiu o acesso público ao código-fonte do RHEL, testou
os dois ao mesmo tempo — e o fato de o Rocky Linux ter conseguido manter sua
compatibilidade binária apesar da mudança é evidência de que a arquitetura de
resiliência funcionou como projetada, não apenas no papel.

Por fim, a aplicação prática construída pelo grupo (seção 10) ilustra o
argumento central deste trabalho em miniatura: cada decisão de configuração —
LVM sobre LUKS em vez do inverso, `/boot` fora da criptografia, SSH restrito a
chave pública, um script de auditoria que se recusa a corrigir sozinho o que
encontra — é, antes de tudo, uma decisão sobre quem assume a responsabilidade
quando algo dá errado, e só depois uma decisão técnica. A escolha entre Rocky
Linux e RHEL com subscrição segue exatamente o mesmo princípio: nas duas
colunas o sistema é binariamente o mesmo; o que muda é a quem se recorre — e
quem responde — quando o sistema quebra às três da manhã.

---

## 12. Referências

Todas as fontes foram consultadas em setembro de 2026.

### Fontes primárias

**[P1]** BOWEN, Rich. **CentOS Project shifts focus to CentOS Stream**. CentOS
Project, 8 dez. 2020. Disponível em:
https://blog.centos.org/2020/12/future-is-centos-stream/

**[P2]** ROCKY ENTERPRISE SOFTWARE FOUNDATION. **RESF Approves New Bylaws and
Charter Designed to Ensure Open Community Control of Rocky Linux and Future RESF
Projects**. 11 nov. 2022. Disponível em:
https://rockylinux.org/news/resf-charter-2022-11-11

**[P3]** ROCKY LINUX. **peridot — Cloud-native build system and release tools
tailored to building, releasing, and maintaining Enterprise Linux distributions
and forks**. Repositório de código. Disponível em:
https://git.resf.org/rocky-linux/peridot e https://github.com/rocky-linux/peridot

**[P4]** ROCKY LINUX. **Keeping Open Source Open**. 2023. Disponível em:
https://rockylinux.org/news/keeping-open-source-open

**[P5]** ROCKY LINUX. **Rocky Linux Expresses Confidence Despite Red Hat's
Announcement**. 22 jun. 2023. Disponível em:
https://rockylinux.org/news/2023-06-22-press-release

**[P6]** ROCKY LINUX. **Página oficial do projeto**. Disponível em:
https://rockylinux.org/

**[P7]** ROCKY LINUX. **About**. Disponível em: https://rockylinux.org/about

**[P8]** ROCKY LINUX. **Rocky Linux Release and Version Guide**. Rocky Linux Wiki.
Disponível em: https://wiki.rockylinux.org/rocky/version/

**[P9]** ALMALINUX OS FOUNDATION. **The Future of AlmaLinux is Bright**. jul.
2023. Disponível em: https://almalinux.org/blog/future-of-almalinux/

**[P10]** RED HAT. **Red Hat's commitment to open source: A response to the
git.centos.org changes**. 2023. Disponível em:
https://www.redhat.com/en/blog/red-hats-commitment-open-source-response-gitcentosorg-changes

**[P11]** ROCKY LINUX. **Community Update — June 2021**. jun. 2021. Disponível em:
https://rockylinux.org/news/community-update-june-2021

**[P12]** ROCKY LINUX. **Release Notes for Rocky Linux 8.4**. Documentação
oficial. Disponível em: https://docs.rockylinux.org/release_notes/8_4/

### Fontes secundárias

**[S1]** ENDOFLIFE.DATE. **CentOS**. Disponível em: https://endoflife.date/centos

**[S2]** PROVEN, Liam. **Red Hat strikes a crushing blow against RHEL
downstreams**. The Register, 23 jun. 2023. Disponível em:
https://www.theregister.com/2023/06/23/red_hat_centos_move/

**[S3]** LINUX MAGAZINE. **Introducing Rocky Linux**. Edição 263, 2022. Disponível
em: https://www.linux-magazine.com/Issues/2022/263/Introducing-Rocky-Linux

**[S4]** GOOGLE CLOUD. **CentOS end of support guidance**. Documentação do Compute
Engine. Disponível em:
https://docs.cloud.google.com/compute/docs/eol/centos-eol-guidance

**[S5]** CIQ. **The Founding Story of CIQ — Gregory Kurtzer e Rocky Linux**.
Disponível em: https://ciq.com/company/founding-story

**[S6]** ENDOFLIFE.DATE. **Rocky Linux**. Disponível em:
https://endoflife.date/rocky-linux

---

### Controle do entregável

- [x] Mínimo de 8 referências — **18** (12 primárias, 6 secundárias)
- [x] Mínimo de 4 primárias — **12**
- [x] 12 a 20 páginas no PDF final — **12 páginas**, no limite mínimo
- [x] Seções 10 e 11 preenchidas com base na parte prática (specs da VM,
      diagrama, evidência de SSH); comandos e saídas completas ficaram no
      `.pptx`, não neste documento
- [ ] Revisão final por todos os integrantes
