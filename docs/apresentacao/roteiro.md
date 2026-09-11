# Roteiro da apresentação — 30 minutos cronometrados

**Regras:** todos os integrantes apresentam alguma parte (quem não apresenta não
recebe a nota de apresentação). Desconto de **−2 pontos por minuto excedido**.

---

## Divisão do tempo

| Bloco | Tempo | Conteúdo | Responsável |
|---|---|---|---|
| 1 | **4 min** | Abertura e distribuição — quem mantém o Rocky, ciclo de vida, quando escolher | _(preencher)_ |
| 2 | **5 min** | Esquema de particionamento — o diagrama e a justificativa de cada decisão | _(preencher)_ |
| 3 | **7 min** | Instalação com LVM e LUKS — ao vivo ou vídeo acelerado, comentando os pontos críticos | _(preencher)_ |
| 4 | **6 min** | Serviço SSH endurecido — acesso por chave funcionando **e** tentativa bloqueada | _(preencher)_ |
| 5 | **5 min** | Script `user-audit.sh` — arquitetura e execução ao vivo com saída real | _(preencher)_ |
| 6 | **3 min** | As cinco perguntas aplicadas à turma | _(preencher)_ |

Total: **30 min**.

---

## Bloco 1 — Abertura e distribuição (4 min)

Pontos obrigatórios:
- Quem mantém o Rocky Linux: **RESF**, e por que essa estrutura foi escolhida.
- O contexto: o fim do CentOS Linux e a inversão upstream/downstream.
- **Bug-for-bug compatibility** — explicar o conceito, não só citar.
- **Peridot** — build system aberto, e por que isso é argumento de resiliência.
- Ciclo de vida e quando escolher Rocky em vez de RHEL com subscrição.

## Bloco 2 — Particionamento (5 min)

- Mostrar o diagrama.
- Justificar **LVM sobre LUKS** (uma passphrase, herança automática).
- Explicar por que `/boot` fica fora e **qual é o risco residual** — a banca
  provavelmente vai perguntar isso.
- Explicar por que espaço livre no VG é requisito.
- Mostrar a tabela de opções de montagem, com **o ataque que cada uma bloqueia**.

## Bloco 3 — Instalação (7 min)

- Gravar vídeo acelerado como plano principal; instalação ao vivo é arriscada
  em 7 minutos.
- Comentar os pontos críticos: escolha do UEFI, particionamento manual, marcar
  Encrypt, não alocar 100% do VG.
- Mostrar as evidências: `lsblk -f`, `luksDump`, `pvs/vgs/lvs`, `findmnt`.
- Demonstrar o ciclo de vida do LVM com o segundo disco (`pvcreate` →
  `vgextend` → `lvextend` → `xfs_growfs` a quente).

## Bloco 4 — SSH (6 min)

- Mostrar `sshd -T` com a configuração efetiva.
- **Demonstrar acesso por chave funcionando.**
- **Demonstrar tentativa bloqueada** e o registro correspondente no `journald`.
- Mostrar `firewall-cmd --list-all` e `semanage port -l | grep ssh`.
- Citar a regra de ouro: validar em sessão paralela antes de fechar a atual.

## Bloco 5 — Script (5 min)

- Arquitetura: funções, códigos de saída, logging, `trap`/`mktemp`.
- Destacar que o script é **somente de leitura** — decisão de projeto, não
  limitação.
- Executar ao vivo com saída real. **Ensaiar na máquina que será usada.**
- Mostrar `shellcheck` limpo.

## Bloco 6 — Perguntas (3 min)

Aplicar o questionário de `perguntas-gabarito.md`. Um slide com a pergunta, o
seguinte com a resposta comentada.

---

## Ensaio

| Ensaio | Data | Tempo total | Ajustes necessários |
|---|---|---|---|
| 1 | __/__/____ | __ min | |
| 2 | __/__/____ | __ min | |
| 3 (final) | __/__/____ | __ min | |

---

## Plano B

- [ ] Vídeo da instalação gravado (caso a demo ao vivo falhe)
- [ ] Vídeo da demo de SSH gravado
- [ ] Saída do script salva em texto (caso a execução ao vivo falhe)
- [ ] Slides em PDF além do `.pptx` (caso o PowerPoint não abra)
