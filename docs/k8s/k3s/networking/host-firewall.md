# Firewall dos nós K3s

Estas regras complementam o [firewall básico dos hosts](../../../security/hosts/firewall.md). Nos hosts K3s, libere também a comunicação interna do cluster. Restrinja `K3S_NODE_CIDR` à rede que contém somente os nós; nunca exponha VXLAN/UDP 8472 à Internet.

Nos managers e agents:

> **Executar em:** todos os nós manager e agent, como `root`.

```bash
bash <<'EOF'
set -euo pipefail

read -r -p "CIDR da rede privada dos nós: " K3S_NODE_CIDR </dev/tty
read -r -p "CIDR dos Pods [10.42.0.0/16]: " K3S_POD_CIDR </dev/tty
read -r -p "CIDR dos Services [10.43.0.0/16]: " K3S_SERVICE_CIDR </dev/tty

K3S_POD_CIDR="${K3S_POD_CIDR:-10.42.0.0/16}"
K3S_SERVICE_CIDR="${K3S_SERVICE_CIDR:-10.43.0.0/16}"

if [[ -z "${K3S_NODE_CIDR}" ]]; then
  printf 'O CIDR dos nós não pode ficar vazio.\n' >&2
  exit 1
fi

# Em todos os nós: Flannel VXLAN e métricas/API do kubelet.
ufw allow in from "${K3S_NODE_CIDR}" to any port 8472 proto udp
ufw allow in from "${K3S_NODE_CIDR}" to any port 10250 proto tcp

# CIDRs padrão dos pods e serviços do K3s.
ufw allow in from "${K3S_POD_CIDR}"
ufw allow in from "${K3S_SERVICE_CIDR}"
EOF
```

Somente nos managers:

> **Executar em:** todos os nós manager, como `root`.

```bash
bash <<'EOF'
set -euo pipefail

read -r -p "CIDR da rede privada dos nós: " K3S_NODE_CIDR </dev/tty

if [[ -z "${K3S_NODE_CIDR}" ]]; then
  printf 'O CIDR dos nós não pode ficar vazio.\n' >&2
  exit 1
fi

# Supervisor e API Kubernetes.
ufw allow in from "${K3S_NODE_CIDR}" to any port 6443 proto tcp

# Comunicação entre managers com etcd embarcado.
ufw allow in from "${K3S_NODE_CIDR}" to any port 2379:2380 proto tcp
EOF
```

Se a API também for administrada por uma rede separada, acrescente uma regra TCP/6443 restrita a essa rede. Se usar Flannel WireGuard em vez de VXLAN, libere UDP/51820 e, para IPv6, UDP/51821 entre os nós no lugar de UDP/8472. Exponha TCP/80, TCP/443 e NodePorts somente quando a arquitetura dos serviços exigir.

## Fontes e leitura adicional

- [K3s — Requirements: Networking](https://docs.k3s.io/installation/requirements#networking) — Mantém a tabela oficial de portas, origens e destinos exigidos por API, Flannel, kubelet e etcd.
- [K3s — Basic Network Options](https://docs.k3s.io/networking/basic-network-options) — Detalha os backends VXLAN e WireGuard do Flannel e as opções de rede alternativas.
- [Ubuntu Server — Firewall](https://ubuntu.com/server/docs/how-to/security/firewalls/) — Referência oficial do Ubuntu para configurar e revisar regras com UFW.
- [Kubernetes — Service](https://kubernetes.io/docs/concepts/services-networking/service/) — Explica os tipos de Service, incluindo `NodePort` e `LoadBalancer`, que podem exigir portas adicionais nos hosts.
