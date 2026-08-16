# Arquitetura — CLD-DOCKER-SECURITY-LAB

## Visão geral

Cada "caso" (`cases/0X-*`) representa uma stack de aplicação real (Node,
Python/Flask, Nginx estático) com duas variantes de Dockerfile lado a lado:
`vulnerable/` e `hardened/`. Dois arquivos `docker-compose` no topo do
repositório orquestram os três casos simultaneamente, em modo vulnerável ou
hardened, para permitir comparação de scan em lote.

```
              ┌───────────────────────────────┐
              │   docker-compose.vulnerable.yml│
              │   docker-compose.hardened.yml  │
              └───────────────┬─────────────────┘
                               │
        ┌──────────────────────┼──────────────────────┐
        ▼                      ▼                       ▼
 cases/01-node-express   cases/02-python-flask   cases/03-nginx-static
  {vulnerable,hardened}   {vulnerable,hardened}   {vulnerable,hardened}
        │                      │                       │
        └──────────────────────┴──────────────────────┘
                               │
                               ▼
                 scanning/ (Trivy, Grype/Clair, hadolint)
                               │
                               ▼
              docs/remediation-reports/CLD-D0X-*.md
```

## Casos

| Caso | Stack | Foco da vulnerabilidade |
|---|---|---|
| `01-node-express` | Node.js + Express | Root user, segredo em ENV, imagem EOL |
| `02-python-flask` | Python + Flask | Segredo em ARG, debug mode / RCE potencial |
| `03-nginx-static` | Nginx estático | Root user, tag `latest`, vazamento de versão |

## Fluxo de uso recomendado

1. `docker compose -f docker-compose.vulnerable.yml build`.
2. `bash scanning/run-trivy.sh` (ou `run-clair.sh`) para gerar relatórios.
3. Repita para `docker-compose.hardened.yml` e compare os relatórios.
4. `bash tests/run-hadolint.sh` para lint estático de todos os Dockerfiles.
5. Leia o relatório de remediação correspondente em
   `docs/remediation-reports/` para entender o "porquê" de cada correção.
