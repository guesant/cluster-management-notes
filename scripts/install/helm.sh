#!/usr/bin/env bash

set -euo pipefail

echo "==> Instalando Helm..."

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
rm -f ./get_helm.sh

echo
helm version
echo

echo "==> Helm instalado com sucesso."
