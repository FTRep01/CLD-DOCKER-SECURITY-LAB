# CLD-DOCKER-SECURITY-LAB

**Laboratório de Docker Security: Dockerfiles inseguros vs. corrigidos (hardening de containers), com varredura de vulnerabilidades via Trivy/Grype e relatórios de remediação caso-a-caso.**

![status](https://img.shields.io/badge/status-active-2ea44f)
![focus](https://img.shields.io/badge/focus-container%20security-cf222e)
![scope](https://img.shields.io/badge/scope-defensive%20research-0969da)
![tooling](https://img.shields.io/badge/tooling-Trivy%20%7C%20hadolint-844fba)
![reports](https://img.shields.io/badge/reports-Markdown-6e7781)
![validation](https://img.shields.io/badge/validation-automated-2ea44f)

> ⚠️ **Aviso importante:** as imagens em `cases/*/vulnerable` são
> **intencionalmente inseguras** para fins educacionais (segredos hardcoded,
> root, debug mode). Construa e rode apenas em ambiente isolado (sua máquina
> local ou um sandbox descartável), nunca exponha essas imagens à internet.

---

## O que é

Três casos reais de containerização (**Node/Express**, **Python/Flask**,
**Nginx estático**), cada um com:

- Uma versão **vulnerável** (`cases/0X-*/vulnerable`) — más práticas comuns
  encontradas em código real: root user, segredos em `ENV`/`ARG`, imagens
  base desatualizadas, debug mode habilitado, sem healthcheck.
- Uma versão **hardened** (`cases/0X-*/hardened`) — corrigida com multi-stage
  build, usuário não-root, segredos injetados em runtime, imagens mínimas e
  atualizadas, healthcheck e configuração de runtime restritiva.
- Um **relatório de remediação** em `docs/remediation-reports/`, no padrão
  descrição → evidência → impacto → correção → validação → referências.
- Scripts prontos para escanear ambas as variantes com **Trivy** (e uma
  alternativa via **Grype/Clair**), além de lint estático com **hadolint**.

## Por que este projeto existe

"Hardening de container" costuma ser explicado de forma abstrata (lista de
boas práticas). Este projeto mostra o **diff concreto** entre o Dockerfile
real que causa o problema e o Dockerfile real que resolve, com o relatório
de scan (Trivy) comprovando a redução de CVEs/misconfigurations — e uma
demonstração de **cadeia de ataque** ligando as vulnerabilidades isoladas a
um cenário de comprometimento de container ponta a ponta.

## Arquitetura

```
docker-compose.{vulnerable,hardened}.yml
        │
        ▼
cases/{01-node-express,02-python-flask,03-nginx-static}/{vulnerable,hardened}
        │
        ▼
scanning/ (Trivy, Grype/Clair)  +  tests/ (hadolint)
        │
        ▼
docs/remediation-reports/CLD-D0X-*.md
```

Detalhamento completo em [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) e
checklist consolidado em
[`docs/HARDENING-CHECKLIST.md`](docs/HARDENING-CHECKLIST.md).

## Módulos (casos)

| Caso | Stack | Vulnerabilidade central |
|---|---|---|
| `cases/01-node-express` | Node.js + Express | Root user, segredo em `ENV`, imagem `node:14` (EOL) |
| `cases/02-python-flask` | Python + Flask | Segredo em `ARG`, `FLASK_DEBUG=1` (RCE potencial) |
| `cases/03-nginx-static` | Nginx estático | Root user, tag `latest`, `server_tokens` vazando versão |

## Instalação

Pré-requisitos:

```bash
docker --version

# Trivy: https://aquasecurity.github.io/trivy/latest/getting-started/installation/
trivy --version

# Grype (alternativa mais simples ao Clair): https://github.com/anchore/grype
grype version

# hadolint: https://github.com/hadolint/hadolint#install
hadolint --version
```

```bash
git clone https://github.com/<seu-usuario>/CLD-DOCKER-SECURITY-LAB.git
cd CLD-DOCKER-SECURITY-LAB
```

## Uso

```bash
# Build de todas as imagens vulneráveis
make build-vuln

# Build de todas as imagens hardened
make build-hardened

# Escanear todas com Trivy (build + scan, salva relatórios comparativos)
make scan

# Lint estático de todos os Dockerfiles
make lint

# Subir a stack hardened localmente
docker compose -f docker-compose.hardened.yml up
```

## Estrutura de um caso

Cada caso `CLD-D0X` segue sempre a mesma estrutura:

```
cases/<stack>/vulnerable/Dockerfile   -> Inseguro, comentado explicando o "porquê"
cases/<stack>/hardened/Dockerfile     -> Corrigido, comentado com as contramedidas
docs/remediation-reports/CLD-D0X-*.md -> Relatório: descrição, impacto, correção, validação
scanning/sample-reports/trivy-<stack>-{vulnerable,hardened}.json -> Amostra de scan
```

## Demonstração: detectando uma cadeia de ataque

O arquivo [`attack-chain-demo/DEMO.md`](attack-chain-demo/DEMO.md) conecta os
casos isolados numa cadeia realista: vazamento de segredo via endpoint →
debug mode habilitado → confirmação de root dentro do container → fuga via
`--privileged` → persistência não detectada por imagem base desatualizada —
mostrando qual scanner/prática interrompe cada elo.

## Testes

```bash
# Vulnerability scanning (Trivy)
bash scanning/run-trivy.sh

# Alternativa Grype/Clair
bash scanning/run-clair.sh

# Lint estático de Dockerfile
bash tests/run-hadolint.sh
```

Resultado esperado (ver `scanning/sample-reports/`): dezenas de findings
CRITICAL/HIGH nas imagens vulneráveis (CVEs de SO desatualizado + segredos
detectados) e **zero CRITICAL/HIGH** nas imagens hardened.

Um workflow de CI pronto (GitHub Actions) está em
[`scanning/ci/github-actions-trivy.yml`](scanning/ci/github-actions-trivy.yml) —
basta copiar para `.github/workflows/trivy.yml` no seu repositório real.

## Estrutura do repositório

```
CLD-DOCKER-SECURITY-LAB/
├── README.md
├── LICENSE
├── Makefile
├── docker-compose.vulnerable.yml
├── docker-compose.hardened.yml
├── docs/
│   ├── ARCHITECTURE.md
│   ├── HARDENING-CHECKLIST.md
│   └── remediation-reports/
│       ├── CLD-D01-root-user.md
│       ├── CLD-D02-secrets-in-image.md
│       ├── CLD-D03-outdated-base-image.md
│       ├── CLD-D04-no-healthcheck-excess-privileges.md
│       └── CLD-D05-package-manager-cache-bloat-cve.md
├── cases/
│   ├── 01-node-express/{vulnerable,hardened}
│   ├── 02-python-flask/{vulnerable,hardened}
│   └── 03-nginx-static/{vulnerable,hardened}
├── scanning/
│   ├── run-trivy.sh
│   ├── run-clair.sh
│   ├── trivy-ignore-policy.yaml
│   ├── ci/github-actions-trivy.yml
│   └── sample-reports/
├── attack-chain-demo/
│   └── DEMO.md
└── tests/
    ├── .hadolint.yaml
    └── run-hadolint.sh
```

## Roadmap

- [ ] Adicionar caso CLD-D06: imagem multi-arquitetura assinada (Cosign/Sigstore).
- [ ] Adicionar caso CLD-D07: SBOM (Software Bill of Materials) gerado via
      `trivy sbom` / `syft` para cada imagem hardened.
- [ ] Integração com admission controller (Kyverno/OPA Gatekeeper) bloqueando
      deploy de imagens root ou sem assinatura em um cluster Kubernetes de teste.
- [ ] Exportar relatórios Trivy em SARIF consolidado para GitHub Code Scanning
      (workflow já parcialmente coberto em `scanning/ci/`).
- [ ] Adicionar variante "distroless" para o caso Node como comparação extra.

## Referências

- CIS Docker Benchmark.
- NIST SP 800-190 — Application Container Security Guide.
- OWASP Docker Top 10.
- [Trivy](https://aquasecurity.github.io/trivy/) — documentação oficial.
- [Grype](https://github.com/anchore/grype) e [Clair](https://quay.github.io/clair/) — scanners de vulnerabilidade de imagem.
- [hadolint](https://github.com/hadolint/hadolint) — linter de Dockerfile.
- Docker Official Best Practices for Writing Dockerfiles.

---

*Projeto educacional criado com apoio do Claude (Anthropic) para fins de
estudo em Container/DevSecOps. Identificadores `CLD-D0X` usados como
convenção de rastreabilidade dos casos.*
