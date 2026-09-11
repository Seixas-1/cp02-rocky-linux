# 04 — Script `user-audit.sh`

Coletar na VM:

```bash
{ echo '$ shellcheck user-audit.sh'; shellcheck ../../scripts/user-audit.sh; echo "código de saída: $?"; } > shellcheck.txt 2>&1

{ echo '$ bash user-audit.sh --help'; bash ../../scripts/user-audit.sh --help; } > help.txt 2>&1

sudo ../../scripts/user-audit.sh --sem-cor --saida execucao.txt
echo "código de saída: $?" >> execucao.txt
```

## Arquivos esperados

- [ ] `shellcheck.txt` — **sem erros** (requisito da rubrica)
- [ ] `help.txt` — saída de `--help`
- [ ] `execucao.txt` — execução completa com saída real
- [ ] `codigos-de-saida.txt` — demonstração dos quatro códigos

## Demonstração dos códigos de saída

```bash
# 2 — erro de uso
./user-audit.sh --opcao-inexistente ; echo "saida=$?"
./user-audit.sh --dias abc          ; echo "saida=$?"

# 3 — privilégio insuficiente (sem sudo)
./user-audit.sh                     ; echo "saida=$?"

# 0 ou 1 — sem achados / com achados
sudo ./user-audit.sh                ; echo "saida=$?"
```

## Demonstração de idempotência

```bash
sudo ./user-audit.sh --sem-cor --saida /tmp/exec1.txt
sudo ./user-audit.sh --sem-cor --saida /tmp/exec2.txt
diff <(grep -v 'Data/hora' /tmp/exec1.txt) <(grep -v 'Data/hora' /tmp/exec2.txt) && echo "idempotente"
```

- [ ] `idempotencia.txt`

## Demonstração do log

```bash
sudo tail -n 20 /var/log/user-audit.log
```

- [ ] `log.txt` — mostrando timestamp e níveis INFO/WARN/ERROR

## Achados encontrados e o que o grupo fez

| Achado | Corrigido? | Como | Evidência |
|---|---|---|---|
| _(preencher)_ | | | |

> O script **não corrige nada** por decisão de projeto. Toda correção acima foi
> aplicada manualmente e reauditada.

## Notas do grupo

_(registrar aqui qualquer particularidade da coleta)_
