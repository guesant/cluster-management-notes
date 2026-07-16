#!/usr/bin/env bash

set -euo pipefail

echo "==> Instalando longhornctl..."

ARCH="$(uname -m)"
case "$ARCH" in
  x86_64)
    LONGHORNCTL_ARCH="amd64"
    ;;
  aarch64|arm64)
    LONGHORNCTL_ARCH="arm64"
    ;;
  *)
    echo "Arquitetura não suportada: $ARCH" >&2
    exit 1
    ;;
esac

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

# Permite fixar uma versão:
# LONGHORNCTL_VERSION=v1.12.0 ./install.sh
if [[ -z "${LONGHORNCTL_VERSION:-}" ]]; then
  LATEST_RELEASE_URL="$(
    curl -fsSL \
      -o /dev/null \
      -w '%{url_effective}' \
      https://github.com/longhorn/cli/releases/latest
  )"

  LONGHORNCTL_VERSION="${LATEST_RELEASE_URL##*/}"
fi

if [[ ! "$LONGHORNCTL_VERSION" =~ ^v[0-9]+\.[0-9]+\.[0-9]+([.-].*)?$ ]]; then
  echo "Versão inválida: ${LONGHORNCTL_VERSION}" >&2
  exit 1
fi

ASSET="longhornctl-linux-${LONGHORNCTL_ARCH}"
DOWNLOAD_URL="https://github.com/longhorn/cli/releases/download/${LONGHORNCTL_VERSION}"

echo "==> Instalando longhornctl ${LONGHORNCTL_VERSION} (${LONGHORNCTL_ARCH})..."

curl -fsSLo "${TMP_DIR}/${ASSET}" \
  "${DOWNLOAD_URL}/${ASSET}"

curl -fsSLo "${TMP_DIR}/${ASSET}.sha256" \
  "${DOWNLOAD_URL}/${ASSET}.sha256"

EXPECTED_SHA256="$(
  awk '{print $1}' "${TMP_DIR}/${ASSET}.sha256"
)"

echo "${EXPECTED_SHA256}  ${TMP_DIR}/${ASSET}" |
  sha256sum --check

sudo install -o root -g root -m 0755 \
  "${TMP_DIR}/${ASSET}" \
  /usr/local/bin/longhornctl

echo
longhornctl version
echo
echo "==> longhornctl instalado com sucesso."
