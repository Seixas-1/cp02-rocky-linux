# CP 02 — Ambiente Linux (RHEL) · Grupo 2 · Rocky Linux

Trabalho em grupo de **Sistemas Operacionais Linux / Cibersegurança** — FIAP.
Instalação segura de Rocky Linux com **LVM sobre LUKS**, endurecimento do serviço
**SSH** e script de auditoria em **Shell**.

> **Escopo:** todo procedimento deste repositório foi executado exclusivamente em
> máquina virtual de propriedade do grupo, em rede NAT/Host-Only isolada. Nenhum
> comando foi aplicado em equipamento da instituição, de empresa ou de terceiros.

---

## Integrantes

| Nome | RM | Responsabilidade principal |
|---|---|---|
| Enzo Seixas | 572294 | Repositório GitHub e documentação |
| João Pedro Ribeiro | 570090 | Particionamento, LUKS/LVM e vídeo da instalação |
| Guilherme Benjamin | 573724 | Configuração do serviço SSH e firewalld |
| Pedro Rossi | 571590 | Script `user-audit.sh` |
| João Iudi | 573667 | Apresentação — slides `.pptx` |
| Luana Godoy | 562776 | Apresentação — slides `.pptx` |

> Todos os integrantes apresentam alguma parte (exigência da rubrica) e todos
> devem ter commits próprios no histórico.

---

## Atribuição do grupo

| Item | Valor |
|---|---|
| Distribuição | **Rocky Linux** |
| Recorte da pesquisa | RESF, compatibilidade *bug-for-bug*, Peridot, fim do CentOS |
| Script exclusivo | `scripts/user-audit.sh` — auditoria de contas, senhas e privilégios |

---

## Estrutura do repositório

```
.
├── README.md                       # este arquivo
├── INSTALL.md                      # guia de instalação reproduzível (entregável 03)
├── USO-DE-IA.md                    # declaração obrigatória de uso de IA generativa
├── CHECKLIST.md                    # checklist de entrega e marcos D-21 → D-0
├── docs/
│   ├── diagrama-particionamento.md # entregável do marco D-14
│   ├── apresentacao/
│   │   ├── roteiro.md              # divisão dos 30 minutos por integrante
│   │   └── perguntas-gabarito.md   # entregável 05 (gabarito: 48h de antecedência)
│   └── pesquisa/
│       ├── esboco.md               # estrutura do documento de 12 a 20 páginas
│       └── referencias.md          # mínimo 8 referências, 4 primárias
├── scripts/
│   └── user-audit.sh               # entregável 04
└── evidencias/
    ├── 01-sistema/                 # os-release, uname, getenforce, sestatus
    ├── 02-disco-luks-lvm/          # lsblk, luksDump, pvs/vgs/lvs, findmnt, fstab
    ├── 03-ssh-firewall/            # sshd -T, firewall-cmd, ss, semanage
    └── 04-script/                  # shellcheck, --help, execução completa
```

---

## Como rodar o script de auditoria

Na VM do grupo, como root:

```bash
sudo ./scripts/user-audit.sh --help
sudo ./scripts/user-audit.sh
sudo ./scripts/user-audit.sh --dias 90 --saida /tmp/relatorio-user-audit.txt
```

Códigos de saída: `0` sem achados · `1` com achados · `2` erro de uso · `3` dependência ausente.

O script é **somente de leitura**: não cria, altera nem remove contas, senhas ou
regras de sudo. Toda correção apontada é aplicada manualmente pelo administrador.

---

## Verificação de qualidade

```bash
shellcheck scripts/user-audit.sh
```

A saída do `shellcheck` deve estar limpa — é requisito da rubrica.
