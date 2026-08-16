#!/usr/bin/env bash
# Alternativa usando Clair (via clairctl) OU Grype (mais simples de rodar
# localmente sem subir um servidor Clair). Por padrão usamos Grype aqui,
# documentando a alternativa Clair para ambientes que já possuem o servidor.
set -euo pipefail

if command -v grype >/dev/null 2>&1; then
  echo ">> Usando Grype (alternativa leve ao Clair)"
  CASES=("01-node-express" "02-python-flask" "03-nginx-static")
  mkdir -p scanning/sample-reports
  for case in "${CASES[@]}"; do
    for variant in vulnerable hardened; do
      tag="cld-${case}-${variant}"
      docker build -t "${tag}" "cases/${case}/${variant}"
      grype "${tag}" -o json > "scanning/sample-reports/grype-${case}-${variant}.json" || true
    done
  done
  exit 0
fi

echo "Grype não encontrado. Para usar Clair diretamente:"
echo "  1. Suba o servidor: docker run -d --name clair -p 6060:6060 quay.io/projectquay/clair:4.7.0"
echo "  2. Use o cliente clairctl para submeter cada imagem ao servidor."
echo "  Docs: https://quay.github.io/clair/"
exit 1
