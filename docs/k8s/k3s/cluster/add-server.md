# Adicionar servidor

Em cada servidor adicional, execute o bloco e informe o token recuperado do gerenciador de segredos:

> **Executar em:** host que será acrescentado como nó manager, como `root`.

```bash
bash <<'EOF'
set -euo pipefail

if (( EUID != 0 )); then
  printf 'Execute este bloco em um shell root aberto com sudo -i.\n' >&2
  exit 1
fi

read -r -p "Versão do K3s [v1.36.1+k3s1]: " K3S_VERSION </dev/tty
K3S_VERSION="${K3S_VERSION:-v1.36.1+k3s1}"

read -r -p "IP deste nó: " K3S_NODE_IP </dev/tty
read -r -p "Nome único deste nó: " K3S_NODE_NAME </dev/tty
read -r -p "Host ou IP estável da API: " K3S_API_HOST </dev/tty
read -r -s -p "Token do cluster: " K3S_TOKEN </dev/tty
printf '\n' >/dev/tty

for REQUIRED_VAR in K3S_NODE_IP K3S_NODE_NAME K3S_API_HOST K3S_TOKEN; do
  if [[ -z "${!REQUIRED_VAR}" ]]; then
    printf '%s não pode ficar vazio.\n' "${REQUIRED_VAR}" >&2
    exit 1
  fi
done

install -d -o root -g root -m 0700 /etc/rancher/k3s

umask 077
cat >/etc/rancher/k3s/config.yaml <<K3S_CONFIG
server: "https://${K3S_API_HOST}:6443"
token: "${K3S_TOKEN}"
node-ip: "${K3S_NODE_IP}"
node-name: "${K3S_NODE_NAME}"
tls-san:
  - "${K3S_API_HOST}"
  - "${K3S_NODE_IP}"
disable:
  - local-storage
secrets-encryption: true
K3S_CONFIG

chmod 0600 /etc/rancher/k3s/config.yaml

curl -sfL https://get.k3s.io \
  | INSTALL_K3S_VERSION="${K3S_VERSION}" sh -s - server

export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

systemctl --no-pager --full status k3s
kubectl wait --for=condition=Ready "node/${K3S_NODE_NAME}" --timeout=180s
kubectl get nodes -o wide
EOF
```

!!! note
    Um cluster de dois servidores com etcd embarcado não oferece o quorum esperado para HA. Prefira três servidores.

## Fontes e leitura adicional

- [K3s — High Availability Embedded etcd](https://docs.k3s.io/datastore/ha-embedded) — Mostra como adicionar servidores ao etcd embarcado e explica a necessidade de um número ímpar de membros.
- [K3s — `k3s server`](https://docs.k3s.io/cli/server) — Referência dos parâmetros de associação ao cluster e dos valores críticos que devem coincidir entre servidores.
- [K3s — Configuration Options](https://docs.k3s.io/installation/configuration) — Documenta o uso do arquivo `config.yaml` e o erro causado por configurações críticas divergentes.
- [K3s — Token Management](https://docs.k3s.io/cli/token) — Explica a autenticação de novos servidores, o formato seguro do token e os cuidados de armazenamento.
