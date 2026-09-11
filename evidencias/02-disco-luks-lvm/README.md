# 02 — Disco, LUKS e LVM

Coletar na VM, como root:

```bash
{ echo '$ lsblk -f';                    lsblk -f;                    } > lsblk.txt      2>&1
{ echo '$ cryptsetup luksDump /dev/sda3'; cryptsetup luksDump /dev/sda3; } > luksdump.txt   2>&1
{ echo '$ pvs'; pvs; echo; echo '$ vgs'; vgs; echo; echo '$ lvs'; lvs; } > lvm.txt        2>&1
{ echo '$ findmnt -o TARGET,SOURCE,FSTYPE,OPTIONS'; findmnt -o TARGET,SOURCE,FSTYPE,OPTIONS; } > findmnt.txt 2>&1
{ echo '$ cat /etc/fstab';    cat /etc/fstab;    } > fstab.txt    2>&1
{ echo '$ cat /etc/crypttab'; cat /etc/crypttab; } > crypttab.txt 2>&1
```

## Arquivos esperados

- [ ] `lsblk.txt`
- [ ] `luksdump.txt` — confirmar `Version: 2` e o KDF em uso
- [ ] `lvm.txt` — o VG **não** pode estar 100% alocado
- [ ] `findmnt.txt` — as opções restritivas devem aparecer aqui
- [ ] `fstab.txt`
- [ ] `crypttab.txt`

## Ciclo de vida do LVM (segundo disco)

Coletar **antes e depois** da extensão, para provar que foi feita a quente:

- [ ] `lvm-antes.txt` — `vgs` e `df -h /var` antes
- [ ] `pvcreate-vgextend.txt`
- [ ] `lvextend-xfsgrowfs.txt`
- [ ] `lvm-depois.txt` — `vgs` e `df -h /var` depois

## Prints da instalação

- [ ] Telas do particionamento manual no Anaconda
- [ ] Tela de definição da passphrase do LUKS (sem mostrar a passphrase)

## Notas do grupo

_(registrar aqui qualquer particularidade da coleta)_

> **Não commitar** `luks-header.img` nem a passphrase.
