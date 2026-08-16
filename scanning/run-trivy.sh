#!/usr/bin/env bash
# Constrói e escaneia todas as imagens vulnerable/hardened com Trivy,
# salvando relatórios comparativos em scanning/sample-reports/.
set -euo pipefail

command -v trivy >/dev/null 2>&1 || { echo "Instale: https://aquasecurity.github.io/trivy/latest/getting-started/installation/"; exit 1; }

CASES=("01-node-express" "02-python-flask" "03-nginx-static")
mkdir -p scanning/sample-reports

for case in "${CASES[@]}"; do
  for variant in vulnerable hardened; do
    tag="cld-${case}-${variant}"
    echo ">> Build: ${tag}"
    docker build -t "${tag}" "cases/${case}/${variant}"

    echo ">> Trivy scan: ${tag}"
    trivy image --format json --output "scanning/sample-reports/trivy-${case}-${variant}.json" "${tag}" || true

    echo ">> Trivy scan (tabela resumida, severidade CRITICAL/HIGH): ${tag}"
    trivy image --severity CRITICAL,HIGH --format table "${tag}" || true
  done
done

echo ">> Escaneando também os Dockerfiles (misconfig) com Trivy config"
trivy config cases/ || true
