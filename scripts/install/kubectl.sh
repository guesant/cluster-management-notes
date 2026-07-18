#!/usr/bin/env bash

set -euo pipefail

echo "==> Instalando kubectl..."

ARCH="$(uname -m)"
case "$ARCH" in
  x86_64)
    KUBECTL_ARCH="amd64"
    ;;
  aarch64|arm64)
    KUBECTL_ARCH="arm64"
    ;;
  *)
    echo "Arquitetura não suportada: $ARCH"
    exit 1
    ;;
esac

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

VERSION="$(curl -fsSL https://dl.k8s.io/release/stable.txt)"

echo "==> Instalando kubectl ${VERSION} (${KUBECTL_ARCH})..."

curl -fsSLo "${TMP_DIR}/kubectl" \
    "https://dl.k8s.io/release/${VERSION}/bin/linux/${KUBECTL_ARCH}/kubectl"

curl -fsSLo "${TMP_DIR}/kubectl.sha256" \
    "https://dl.k8s.io/release/${VERSION}/bin/linux/${KUBECTL_ARCH}/kubectl.sha256"

echo "$(cat "${TMP_DIR}/kubectl.sha256")  ${TMP_DIR}/kubectl" | sha256sum --check

sudo install -o root -g root -m 0755 \
    "${TMP_DIR}/kubectl" \
    /usr/local/bin/kubectl

echo
kubectl version --client
echo
echo "==> kubectl instalado com sucesso."
