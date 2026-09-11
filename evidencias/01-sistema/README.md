# 01 — Sistema e SELinux

Coletar na VM:

```bash
{ echo '$ cat /etc/os-release'; cat /etc/os-release; } > os-release.txt 2>&1
{ echo '$ uname -r';            uname -r;            } > uname.txt      2>&1
{ echo '$ getenforce';          getenforce;          } > getenforce.txt 2>&1
{ echo '$ sestatus';            sestatus;            } > sestatus.txt   2>&1
```

## Arquivos esperados

- [ ] `os-release.txt`
- [ ] `uname.txt`
- [ ] `getenforce.txt` — **precisa retornar `Enforcing`** (−10 pontos se estiver desligado)
- [ ] `sestatus.txt`
- [ ] `00-checksum-iso.txt` — conferência SHA-256 da ISO baixada

## Notas do grupo

_(registrar aqui qualquer particularidade da coleta)_
