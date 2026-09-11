# 03 — SSH e firewall

Coletar na VM, como root:

```bash
{ echo '$ sshd -T';                       sshd -T;                       } > sshd-T.txt      2>&1
{ echo '$ systemctl status sshd';         systemctl status sshd;         } > sshd-status.txt 2>&1
{ echo '$ firewall-cmd --list-all';       firewall-cmd --list-all;       } > firewalld.txt   2>&1
{ echo '$ ss -tulpn';                     ss -tulpn;                     } > ss.txt          2>&1
{ echo '$ semanage port -l | grep ssh';   semanage port -l | grep ssh;   } > semanage.txt    2>&1
```

## Arquivos esperados

- [ ] `sshd-T.txt` — configuração **efetiva**; conferir `permitrootlogin no`,
      `passwordauthentication no`, `maxauthtries 3`, `logingracetime 30`,
      `clientaliveinterval 300`, `allowgroups sshusers`, `port <nova>`
- [ ] `sshd-status.txt`
- [ ] `firewalld.txt` — só a porta nova liberada, com a rich rule de limite de taxa
- [ ] `ss.txt`
- [ ] `semanage.txt` — a porta nova rotulada como `ssh_port_t`
- [ ] `crypto-policies.txt` — `update-crypto-policies --show`
- [ ] `issue-net.txt` — `cat /etc/issue.net` (banner de aviso legal)

## As duas demonstrações obrigatórias

### Acesso por chave funcionando

```bash
ssh -p <porta> -i ~/.ssh/id_ed25519 -v usuario@<ip-da-vm>
```

- [ ] `acesso-por-chave.txt` — saída do cliente
- [ ] `journal-acesso-ok.txt` — `journalctl -u sshd --since "-5 min"`

### Tentativa corretamente bloqueada

```bash
ssh -p <porta> -o PubkeyAuthentication=no -o PreferredAuthentications=password usuario@<ip-da-vm>
ssh -p <porta> root@<ip-da-vm>
```

- [ ] `tentativa-bloqueada.txt` — saída do cliente
- [ ] `journal-tentativa-bloqueada.txt` — registro correspondente no `journald`

> Tentativas feitas exclusivamente contra a VM do próprio grupo, em rede
> isolada.

## Notas do grupo

_(registrar aqui qualquer particularidade da coleta)_

> **Não commitar** chaves privadas. Apenas `.pub` se necessário.
