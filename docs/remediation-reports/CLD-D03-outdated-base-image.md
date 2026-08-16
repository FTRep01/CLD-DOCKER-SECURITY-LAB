# CLD-D03 — Imagem base desatualizada / não fixada por versão

**Severidade:** Alta
**Casos:** todos (`node:14`, `python:3.9`, `nginx:latest`)
**CWE relacionado:** CWE-1104 (Use of Unmaintained Third Party Components)
**Mapeamento:** CIS Docker Benchmark 4.2 · NIST SP 800-190 seção 3.1

## Descrição
As três imagens vulneráveis usam bases fora do ciclo de suporte
(`node:14`, `python:3.9`) ou a tag `latest` (`nginx:latest`), que não
garante reprodutibilidade de build nem previsibilidade de patch de
segurança. Bases desatualizadas acumulam dezenas de CVEs de SO conhecidas
e nunca corrigidas.

## Evidência
Resumo do `trivy image` (ver `scanning/sample-reports/trivy-*-vulnerable.json`):
- `node:14` → 4 CRITICAL / 22 HIGH (SO) + 2 CRITICAL / 6 HIGH (dependências npm).
- `python:3.9` → 3 CRITICAL / 18 HIGH (SO).
- `nginx:latest` → tag não fixada, versão exata desconhecida no momento do build.

## Impacto
- Superfície de ataque ampliada por vulnerabilidades já publicamente
  conhecidas e catalogadas (CVE), muitas com exploit público disponível.
- Builds não determinísticos (`latest`) podem introduzir regressões ou
  novas CVEs sem que o time perceba a mudança.

## Correção aplicada
1. Migração para imagens `alpine`/`slim` atualizadas e dentro do ciclo de
   suporte (`node:20-alpine`, `python:3.12-slim`,
   `nginxinc/nginx-unprivileged:1.27-alpine`).
2. Recomendação de fixar por digest SHA256 em produção (comentário incluído
   nos Dockerfiles hardened) para builds 100% reprodutíveis.
3. Pipeline de CI (`scanning/ci/github-actions-trivy.yml`) escaneando toda
   alteração em Dockerfile e falhando o PR caso a variante hardened
   introduza CVE CRITICAL.

## Validação
- `trivy image` na variante hardened: 0 CRITICAL / 0 HIGH em todos os três casos.

## Referências
- CIS Docker Benchmark, seção 4.2 ("Ensure that containers use trusted base images").
- NIST SP 800-190, seção 3.1 — Image Countermeasures.
