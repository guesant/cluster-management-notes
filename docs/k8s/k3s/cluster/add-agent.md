# Adicionar agente

Em cada agente, execute o bloco e informe o token recuperado do gerenciador de segredos:

> **Executar em:** host que será acrescentado como nó agent, como `root`.

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
K3S_CONFIG

chmod 0600 /etc/rancher/k3s/config.yaml

curl -sfL https://get.k3s.io \
  | INSTALL_K3S_VERSION="${K3S_VERSION}" sh -s - agent

systemctl --no-pager --full status k3s-agent
EOF
```

Em um servidor ou estação com kubeconfig, valide o nó:

> **Executar em:** qualquer máquina com `KUBECONFIG` e acesso à API.

```bash
kubectl get nodes -o wide
```

## Fontes e leitura adicional

- [K3s — Quick-Start Guide](https://docs.k3s.io/quick-start) — Apresenta o fluxo oficial para registrar agentes com o endereço e o token do servidor.
- [K3s — `k3s agent`](https://docs.k3s.io/cli/agent) — Referência das opções do agent, incluindo `server`, `token`, `node-name` e `node-ip`.
- [K3s — Architecture](https://docs.k3s.io/architecture) — Explica o registro dos agents, o balanceador local e as conexões mantidas com os servers.
- [K3s — Token Management](https://docs.k3s.io/cli/token) — Diferencia tokens de server, agent e bootstrap e descreve como eles autenticam a entrada de nós.
