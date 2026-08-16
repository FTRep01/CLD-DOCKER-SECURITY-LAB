#!/usr/bin/env bash
# Roda hadolint em todos os Dockerfiles do repositório (vulnerable + hardened)
# e imprime um resumo comparativo de findings.
set -euo pipefail

command -v hadolint >/dev/null 2>&1 || { echo "Instale: https://github.com/hadolint/hadolint#install"; exit 1; }

CASES=("01-node-express" "02-python-flask" "03-nginx-static")

for case in "${CASES[@]}"; do
  for variant in vulnerable hardened; do
    dockerfile="cases/${case}/${variant}/Dockerfile"
    echo "=== ${dockerfile} ==="
    hadolint "${dockerfile}" || true
    echo
  done
done
