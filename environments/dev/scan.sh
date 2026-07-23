#!/bin/bash

ROOT=${1:-.}

mkdir -p reports

echo "Running Checkov..."
checkov -d "$ROOT" -o json > reports/checkov.json

echo "Running tfsec..."
tfsec "$ROOT" --format json --out reports/tfsec

echo "Running Terrascan..."
terrascan scan -d "$ROOT" -o json > reports/terrascan.json

echo "Running Semgrep..."
semgrep scan --config auto "$ROOT" --json --output reports/semgrep.json

echo "Running Gitleaks..."
gitleaks detect --source "$ROOT" --report-format json --report-path reports/gitleaks.json

echo "Running TruffleHog..."
trufflehog filesystem "$ROOT" --json > reports/trufflehog.json

echo "Done!"
echo "Running Terraform Init..."
terraform -chdir="$ROOT" init -backend=false -input=false >/dev/null 2>&1

echo "Running TFLint..."
tflint --chdir="$ROOT" --init >/dev/null 2>&1

tflint \
    --chdir="$ROOT" \
    --format json \
    > reports/tflint.json

echo "Running Infracost..."
infracost breakdown \
    --path "$ROOT" \
    --format json \
    --out-file reports/infracost.json
