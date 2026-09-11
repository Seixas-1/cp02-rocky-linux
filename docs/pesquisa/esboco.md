# Documento de pesquisa — esboço

**Requisito:** PDF de 12 a 20 páginas · mínimo 8 referências, 4 primárias.
**Recorte do Grupo 2:** RESF, compatibilidade *bug-for-bug*, Peridot, fim do CentOS.

---

## Estrutura sugerida

### 1. Introdução (1 pág.)
Objetivo do trabalho, escopo e ambiente utilizado.

### 2. O ecossistema Red Hat e por que ele importa (1–2 pág.)
Por que bancos, telecom, governo e grandes varejistas rodam RHEL e derivados.
Diferenças práticas para quem vem do Debian: `dnf`/`rpm` em vez de `apt`/`dpkg`,
`firewalld` em vez de `ufw`/`iptables` direto, Anaconda em vez do
debian-installer, e **SELinux ligado por padrão** — no Debian ele nem vem
habilitado.

### 3. O fim do CentOS (2–3 pág.) — **núcleo do recorte**
- O que o CentOS Linux era: rebuild binário, gratuito, do RHEL.
- O anúncio de dezembro de 2020: descontinuação do CentOS Linux 8 e mudança de
  foco para o **CentOS Stream**.
- A inversão de posição: CentOS Linux vinha **depois** do RHEL (downstream);
  CentOS Stream vem **antes** (upstream, *rolling preview* da próxima minor).
- O impacto: quem usava CentOS em produção porque queria estabilidade
  downstream perdeu exatamente essa propriedade.
- **TODO:** confirmar as datas exatas de EOL do CentOS Linux 8 e do CentOS
  Linux 7 nas fontes primárias.

### 4. O nascimento do Rocky Linux (2 pág.)
- Origem: reação direta ao anúncio, liderada por Gregory Kurtzer, cofundador do
  projeto CentOS original.
- Origem do nome (homenagem a Rocky McGaugh).
- **RESF — Rocky Enterprise Software Foundation**: qual é a estrutura jurídica
  escolhida, o que ela protege e por que essa escolha foi apresentada como
  resposta ao que aconteceu com o CentOS.
- **TODO:** verificar na fonte primária a forma jurídica e a estrutura de
  governança da RESF, e a data da primeira release estável.

### 5. Compatibilidade *bug-for-bug* (2 pág.) — **conceito central**
- O que significa ser *bug-for-bug compatible* com o RHEL, e por que é mais
  forte do que "compatível".
- Por que isso importa comercialmente: software homologado para RHEL (bancos de
  dados, ERPs, agentes de backup) roda sem recertificação.
- ABI/API estáveis dentro de uma major release.
- Comparação com o AlmaLinux, que passou a se posicionar por **compatibilidade
  de ABI** em vez de *bug-for-bug* — e o que muda na prática.
- **Contexto de 2023:** a mudança na disponibilidade pública dos fontes do RHEL
  e como cada rebuild respondeu. **TODO:** apurar nas fontes primárias.

### 6. Peridot — o sistema de build (2 pág.)
- O que é: o build system open source usado para construir o Rocky Linux.
- Por que a existência de um build system aberto e reproduzível é um argumento
  de resiliência: qualquer um pode reconstruir a distribuição, o que reduz a
  dependência de uma única organização.
- Relação com a promessa da RESF de que o Rocky não pode ser "descontinuado"
  unilateralmente.
- **TODO:** descrever a arquitetura do Peridot a partir da documentação oficial.

### 7. Ciclo de vida e suporte (1 pág.)
Janela de suporte por major release, cadência das minor releases, política de
atualizações de segurança. Comparar com RHEL (10 anos), Fedora (~13 meses) e
CentOS Stream (contínuo).

### 8. Quando escolher Rocky Linux (1 pág.)
Cenários em que faz sentido e cenários em que o RHEL com subscrição é melhor
escolha (suporte contratual, Insights, certificações, responsabilidade jurídica).

### 9. Aplicação prática (2–3 pág.)
Resumo do ambiente instalado, do particionamento com LUKS+LVM, do endurecimento
do SSH e do script `user-audit.sh`, com referência às evidências.

### 10. Conclusão (1 pág.)

### 11. Referências

---

## Perguntas que a banca pode fazer — o grupo precisa saber responder

1. Qual é a diferença entre *bug-for-bug compatible* e "compatível com ABI"?
2. Por que o CentOS Stream não substitui o CentOS Linux para quem quer
   estabilidade downstream?
3. O que a estrutura da RESF protege que a governança anterior do CentOS não
   protegia?
4. Se o Rocky é um rebuild do RHEL, de onde vem o código-fonte hoje?
5. Por que ter um build system aberto (Peridot) é um argumento de resiliência?

---

## Regras de qualidade

- Toda afirmação factual precisa de referência. **Datas, versões e números não
  devem ser escritos de memória** — todos os `TODO` acima marcam pontos que
  exigem conferência em fonte primária.
- Fontes primárias aceitáveis: documentação oficial do Rocky Linux, site e
  documentos da RESF, repositório e documentação do Peridot, anúncios oficiais
  do projeto CentOS e da Red Hat, documentação oficial da Red Hat.
- Fontes secundárias (notícias, blogs, artigos) contam para o total de 8, mas
  não substituem as 4 primárias.
