# CLD-D05 — Cache de gerenciador de pacotes na imagem final e builds não determinísticos

**Severidade:** Média
**Casos:** `cases/02-python-flask`, `cases/01-node-express`
**CWE relacionado:** CWE-1104 (Use of Unmaintained Third Party Components), CWE-693 (Protection Mechanism Failure)
**Mapeamento:** CIS Docker Benchmark 4.9 · Docker Official Best Practices — "Minimize layers and image size"

## Descrição
O caso vulnerável do Node usa `npm install` (sem lockfile determinístico e
sem `--omit=dev`), incluindo dependências de desenvolvimento na imagem
final. O caso vulnerável do Python usa `pip install -r requirements.txt`
sem versões travadas e sem `--no-cache-dir`, deixando cache do pip e
possibilitando que uma nova versão de dependência (com CVE) entre
silenciosamente em builds futuros.

## Impacto
- Builds não reprodutíveis: a mesma tag de Dockerfile pode gerar imagens
  com dependências diferentes (e CVEs diferentes) em datas distintas.
- Imagem final maior, aumentando a superfície de ataque e o tempo de
  transferência/deploy.
- Dependências de desenvolvimento (compiladores, ferramentas de teste)
  desnecessárias em produção ampliam o número de CVEs reportadas por scanners.

## Correção aplicada
1. Node: `npm ci` (usa `package-lock.json`, build determinístico) com
   `--omit=dev` na etapa final; `npm cache clean --force` remove o cache.
2. Python: `requirements.txt` com versões exatas travadas
   (`flask==3.0.3`, `gunicorn==22.0.0`); `pip install --no-cache-dir`.
3. Multi-stage build em ambos os casos: ferramentas de build (ex.: `gcc`)
   ficam restritas à etapa de build e não chegam à imagem final.

## Validação
- Comparação de tamanho de imagem: hardened significativamente menor que
  vulnerable (menos layers, sem cache, sem devDependencies).
- `trivy image`: 0 CVEs de dependências de aplicação na variante hardened.

## Referências
- Docker Official Best Practices for Writing Dockerfiles.
- npm docs — diferenças entre `npm install` e `npm ci`.
