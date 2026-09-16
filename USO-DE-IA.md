# Declaração de uso de IA generativa

Documento obrigatório pelo enunciado do CP 02. O uso de IA generativa é
permitido **como apoio**, desde que declarado aqui.

> Conteúdo tecnicamente errado é penalizado independentemente da origem — todo
> material gerado com apoio de IA foi revisado, testado na VM do grupo e é de
> responsabilidade dos integrantes.

---

## Registro de uso

| Data | Integrante | Ferramenta | Onde foi usada | O que foi feito com o resultado |
|---|---|---|---|---|
| 2026-09-10 | Enzo Seixas | Claude (Anthropic) | Estrutura inicial do repositório, esqueleto do `INSTALL.md`, rascunho do `user-audit.sh`, esboço da pesquisa | Revisado pelo grupo; script testado na VM e validado com `shellcheck`; comandos conferidos contra a documentação oficial |
| 2026-09-14 | Enzo Seixas | Claude (Anthropic) | Redação das seções 1 a 9 do documento de pesquisa | Fontes primárias abertas e conferidas uma a uma; datas, versões e números verificados contra os anúncios oficiais; seções 10 e 11 dependem da parte prática e serão escritas pelo grupo |
| 2026-09-12 | Enzo Seixas | IA generativa | Finalização do repositório GitHub e documentação geral do projeto | Conteúdo revisado pelo grupo; comandos e afirmações conferidos contra a documentação oficial |
| 2026-09-12 | Pedro Rossi | IA generativa | Script `user-audit.sh` — escalonamento das demais funções a partir de um script de *briefing* próprio (`cut -d: -f3 /etc/passwd \| sort -n \| uniq -d`) para coletar e comparar UIDs duplicados e senhas, com base nos módulos RH124/RH134 | Revisado e testado na VM; comandos fora do escopo do aprendizado (ex.: `awk`) foram criticados e removidos/substituídos por comandos vistos em aula |
| 2026-09-12 | João Pedro Ribeiro | IA generativa | Roteiro do vídeo da instalação e auxílio em partes práticas (ex.: particionamento) | Usado como apoio; procedimento executado e conferido na VM do grupo |
| 2026-09-12 | Guilherme Benjamin | IA generativa | Roteiro das tarefas de responsabilidade (SSH/firewalld) e passo a passo de instalação sem erros | Usado como apoio; configuração aplicada e testada na VM do grupo |
| 2026-09-12 | João Iudi | IA do Canva | Apresentação (slides `.pptx`) | Apenas para finalização e acabamento visual; conteúdo definido pelo grupo |
| 2026-09-12 | Luana Godoy | IA do Canva | Apresentação (slides `.pptx`) | Apenas para finalização e acabamento visual; conteúdo definido pelo grupo |

---

## O que **não** foi gerado por IA

- _(preencher)_ Evidências de execução — todas coletadas na VM real do grupo.
- _(preencher)_ Decisões sobre conflitos de opções de montagem — resultado de
  teste próprio.
- _(preencher)_ Capturas de tela da instalação.

---

## Verificação feita pelo grupo

- [ ] Todo comando do `INSTALL.md` foi executado na VM e a saída conferida
- [ ] O `user-audit.sh` passa no `shellcheck` sem erros
- [ ] O `user-audit.sh` foi executado e a saída corresponde ao estado real do sistema
- [ ] As afirmações do documento de pesquisa foram conferidas contra as fontes primárias
- [ ] Nenhum trecho foi entregue sem que ao menos um integrante saiba explicá-lo
