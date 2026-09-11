# Evidências

> **Saída em texto é preferida ao print: pode ser conferida. Toda afirmação do
> documento tem que ter evidência correspondente.**

Cada arquivo desta pasta é a saída literal de um comando executado na VM do
grupo. Não editar a saída — se algo precisar de explicação, escrever a nota no
`README.md` da subpasta.

## Como coletar

Rodar o comando redirecionando a saída para o arquivo correspondente:

```bash
comando > evidencias/<subpasta>/<nome>.txt 2>&1
```

Para incluir o comando junto com a saída, o que facilita a conferência:

```bash
{ echo '$ comando'; comando; } > evidencias/<subpasta>/<nome>.txt 2>&1
```

## Subpastas

| Pasta | Conteúdo |
|---|---|
| `01-sistema/` | `os-release`, `uname -r`, `getenforce`, `sestatus` |
| `02-disco-luks-lvm/` | `lsblk -f`, `luksDump`, `pvs/vgs/lvs`, `findmnt`, `fstab`, `crypttab` |
| `03-ssh-firewall/` | `sshd -T`, `systemctl status sshd`, `firewall-cmd --list-all`, `ss -tulpn`, `semanage port -l` |
| `04-script/` | `shellcheck`, `--help`, execução completa |

## Cuidado ao commitar

Não versionar nesta pasta:

- a passphrase do LUKS;
- o arquivo de backup do header LUKS (`luks-header.img`);
- chaves privadas (`id_ed25519`, `*.pem`, `*.key`);
- o conteúdo de `/etc/shadow`.

A saída do `user-audit.sh` **não** contém hashes de senha — apenas nomes de
conta e parâmetros de política. Conferir antes de commitar mesmo assim.
