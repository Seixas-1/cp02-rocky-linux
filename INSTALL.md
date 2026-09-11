# Guia de instalação reproduzível — Rocky Linux com LVM sobre LUKS

Grupo 2 · CP 02 — Ambiente Linux (RHEL)

Este guia permite reproduzir integralmente o ambiente do grupo do zero. Cada
etapa indica o comando executado e a evidência correspondente gravada em
`evidencias/`.

> **Escopo:** todos os procedimentos foram executados em máquina virtual do
> próprio grupo, com rede NAT/Host-Only isolada.

---

## 0. Preparação

### 0.1 Obter e conferir a ISO

Baixar a ISO do Rocky Linux (variante *minimal* ou *dvd*) e o arquivo
`CHECKSUM` do mesmo diretório do espelho oficial.

```bash
sha256sum -c CHECKSUM --ignore-missing
```

> Registrar a saída em `evidencias/01-sistema/00-checksum-iso.txt`.
> **TODO:** anotar a versão exata usada (ex.: Rocky Linux 9.x) e a data do download.

### 0.2 Criar a máquina virtual

| Parâmetro | Valor |
|---|---|
| Firmware | **UEFI** (nunca BIOS legado) |
| Disco principal | 60 GB |
| Disco secundário | 20 GB — **adicionado somente após a instalação** |
| Memória | 4 GB |
| vCPU | 2 |
| Rede | NAT ou Host-Only |
| Tipo de instalação | Server sem GUI / Minimal Install |

> **TODO:** registrar o hipervisor usado e a versão.

### 0.3 Antes de começar

- [ ] **Passphrase do LUKS anotada** em local seguro fora da VM. Sem ela e sem
      backup do header, o dado é perdido em definitivo — não existe recuperação.
- [ ] Plano de snapshots definido (ver seção 6).

---

## 1. Esquema de particionamento

O diagrama e a justificativa de cada decisão estão em
[`docs/diagrama-particionamento.md`](docs/diagrama-particionamento.md)
(entregável do marco D-14, validado **antes** da instalação).

```
sda1  /boot/efi   1 GB    FAT32     fora da criptografia
sda2  /boot       1 GB    xfs       fora da criptografia
sda3  ~58 GB      LUKS2   container criptografado
      └─ VG vg_sistema  (PV = /dev/mapper/cryptlvm)
         lv_root     15 G   /
         lv_var       8 G   /var
         lv_varlog    5 G   /var/log
         lv_vartmp    3 G   /var/tmp
         lv_home     10 G   /home
         lv_tmp       3 G   /tmp
         lv_swap      4 G   swap
         livre       ~9 G   reservado para snapshots
```

---

## 2. Instalação pelo Anaconda

1. Iniciar a VM pela ISO e escolher **Install Rocky Linux**.
2. Em **Installation Destination**, selecionar o disco de 60 GB e marcar
   **Custom** (particionamento manual). Não usar o automático.
3. Escolher o esquema **LVM** no seletor de partições.
4. Criar as partições na ordem da tabela acima:
   - `/boot/efi` — 1 GiB, **EFI System Partition**;
   - `/boot` — 1 GiB, **xfs**, sem criptografia;
   - `/` — marcar **Encrypt** e informar a passphrase. O Anaconda cria o
     container LUKS2 e coloca o volume group inteiro dentro dele.
5. Criar os demais volumes lógicos (`/var`, `/var/log`, `/var/tmp`, `/home`,
   `/tmp`, `swap`) **dentro do mesmo volume group** `vg_sistema`.
6. **Não alocar todo o VG.** Deixar ~9 GiB livres para snapshots.
7. Em **Software Selection**, escolher **Minimal Install** (sem GUI).
8. Em **Security Policy** / após o boot, confirmar que o SELinux está em
   `enforcing`.
9. Criar o usuário administrativo nominal e **não habilitar login de root por
   senha**.

> **TODO:** capturar as telas do particionamento para
> `evidencias/02-disco-luks-lvm/`.

---

## 3. Verificação pós-instalação

Coletar as evidências abaixo em texto — a rubrica prefere saída em texto ao
print porque pode ser conferida.

### 3.1 Sistema e SELinux → `evidencias/01-sistema/`

```bash
cat /etc/os-release
uname -r
getenforce
sestatus
```

`getenforce` **precisa** retornar `Enforcing`. SELinux desligado custa −10 pontos.

### 3.2 Disco, LUKS e LVM → `evidencias/02-disco-luks-lvm/`

```bash
lsblk -f
cryptsetup luksDump /dev/sda3
pvs ; vgs ; lvs
findmnt -o TARGET,SOURCE,FSTYPE,OPTIONS
cat /etc/fstab
cat /etc/crypttab
```

No `luksDump`, confirmar `Version: 2` e registrar o KDF em uso (argon2id).

### 3.3 Backup do header LUKS

```bash
cryptsetup luksHeaderBackup /dev/sda3 --header-backup-file /root/luks-header.img
```

> Guardar o arquivo **fora da VM**. O header corrompido inutiliza o disco mesmo
> com a passphrase correta.

---

## 4. Opções de montagem restritivas

Editar `/etc/fstab` acrescentando as opções abaixo e remontar.

| Ponto de montagem | Opções | O que bloqueia |
|---|---|---|
| `/tmp` | `nodev,nosuid,noexec` | Execução de payload gravado em diretório mundialmente gravável |
| `/var/tmp` | `nodev,nosuid,noexec` | Mesmo vetor, área frequentemente esquecida |
| `/home` | `nodev,nosuid` | Usuário comum criar binário SUID no próprio diretório |
| `/var/log` | `nodev,nosuid,noexec` | Área de log virar ponto de *staging* |
| `/var` | `nodev` | Isola o crescimento de dados de serviço |
| `/boot` | `nodev,nosuid` | Protege a área de boot |

```bash
cp /etc/fstab /etc/fstab.bak-$(date +%F)   # reversibilidade
vi /etc/fstab
mount -o remount /tmp /var/tmp /home /var/log
findmnt -o TARGET,OPTIONS
```

### Conflitos observados

> **TODO — esta seção vale nota.** O professor avisou explicitamente que vai dar
> conflito e que documentar o conflito e a decisão vale mais do que copiar a
> tabela sem testar. Registrar aqui, com evidência:
>
> - `noexec` em `/var` quebra runtimes de container — decisão do grupo: _(…)_
> - `noexec` em `/var/tmp` pode quebrar atualização de pacote que descompacta
>   ali (`dnf`) — teste realizado: _(…)_ · decisão: _(…)_

---

## 5. Ciclo de vida do LVM — segundo disco de 20 GB

Adicionar o disco secundário pelo hipervisor **com a VM ligada ou desligada** e
estender um volume **a quente**, sem desmontar.

```bash
lsblk                                  # identificar o novo disco (ex.: /dev/sdb)
pvcreate /dev/sdb
vgextend vg_sistema /dev/sdb
vgs                                    # espaço livre aumentou
lvextend -L +5G /dev/vg_sistema/lv_var
xfs_growfs /var                        # xfs cresce montado; não aceita reduzir
df -h /var
```

> Todo LV criado a partir daqui nasce dentro do container LUKS — a criptografia
> é herdada do PV, não configurada por volume.

### Snapshot (por isso o VG não pode ficar em 100%)

```bash
lvcreate -s -n snap_root -L 2G /dev/vg_sistema/lv_root
lvs
lvremove /dev/vg_sistema/snap_root
```

---

## 6. Snapshots da VM

Exigência do enunciado — tirar **dois** snapshots no hipervisor:

1. Após a instalação limpa e verificada.
2. Após o SSH endurecido e validado.

---

## 7. Endurecimento do serviço SSH

> **Regra de ouro:** nunca fechar a sessão SSH atual antes de validar a nova
> configuração **em uma segunda sessão aberta em paralelo**.

### 7.1 Par de chaves ed25519 (na estação cliente)

```bash
ssh-keygen -t ed25519 -C "grupo2-cp02"
ssh-copy-id -p 22 usuario@<ip-da-vm>
```

### 7.2 Grupo dedicado de acesso

```bash
groupadd --system sshusers
usermod -aG sshusers <usuario-nominal>
```

### 7.3 Rótulo SELinux da porta nova

Fazer **antes** de mudar a porta no `sshd_config`, senão o serviço não sobe.

```bash
semanage port -a -t ssh_port_t -p tcp 2222
semanage port -l | grep ssh
```

### 7.4 Configuração

```bash
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak-$(date +%F)
vi /etc/ssh/sshd_config
```

```
Port 2222
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
AllowGroups sshusers
MaxAuthTries 3
LoginGraceTime 30
ClientAliveInterval 300
ClientAliveCountMax 2
X11Forwarding no
Banner /etc/issue.net
```

### 7.5 Política criptográfica e banner

```bash
update-crypto-policies --show
update-crypto-policies --set DEFAULT        # ou FUTURE, justificando a escolha
vi /etc/issue.net                            # aviso legal de acesso
```

### 7.6 Validar antes de recarregar

```bash
sshd -t                    # não recarregue se este comando falhar
systemctl reload sshd
```

### 7.7 firewalld

```bash
firewall-cmd --permanent --add-port=2222/tcp
firewall-cmd --permanent --add-rich-rule='rule port port="2222" protocol="tcp" limit value="5/m" accept'
firewall-cmd --permanent --remove-service=ssh
firewall-cmd --reload
firewall-cmd --list-all
```

### 7.8 Evidências → `evidencias/03-ssh-firewall/`

```bash
sshd -T
systemctl status sshd
firewall-cmd --list-all
ss -tulpn
semanage port -l | grep ssh
journalctl -u sshd --since today
```

Capturar **duas** evidências obrigatórias:
- acesso por chave funcionando;
- tentativa por senha corretamente bloqueada (com o registro correspondente no
  `journald`).

---

## 8. Script de auditoria

```bash
shellcheck scripts/user-audit.sh
sudo ./scripts/user-audit.sh --help
sudo ./scripts/user-audit.sh --sem-cor --saida evidencias/04-script/execucao.txt
echo "código de saída: $?"
```

Guardar as três saídas em `evidencias/04-script/`.

---

## 9. Troubleshooting

| Sintoma | Causa provável | Solução |
|---|---|---|
| A VM não boota após a instalação | Firmware em BIOS legado, sem ESP | Recriar a VM com UEFI habilitado |
| Não pede a passphrase e cai no *emergency mode* | `/etc/crypttab` com UUID errado | Conferir `blkid /dev/sda3` contra o `crypttab` |
| `sshd` não sobe após mudar a porta | Porta sem rótulo `ssh_port_t` | `semanage port -a -t ssh_port_t -p tcp 2222` |
| Conexão recusada mesmo com sshd ativo | Porta nova não liberada no firewalld | `firewall-cmd --permanent --add-port=2222/tcp && firewall-cmd --reload` |
| Login por chave falha com AVC no log | Contexto errado em `~/.ssh` | `restorecon -Rv ~/.ssh` |
| `dnf update` falha após aplicar `noexec` | `/var/tmp` com `noexec` | Remontar `/var/tmp` sem `noexec`, atualizar, documentar a decisão |
| `lvextend` reclama de espaço | VG sem extents livres | `vgextend` com o segundo disco antes de estender |
| `xfs_growfs` não reduz o volume | XFS não suporta *shrink* | Recriar o volume; planejar tamanhos na fase de diagrama |

> **TODO:** acrescentar aqui todo problema real enfrentado pelo grupo, com a
> mensagem de erro literal e a solução aplicada. Problemas reais documentados
> valem mais do que a tabela genérica.
