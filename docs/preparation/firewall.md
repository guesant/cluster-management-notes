# Firewall

O firewall do host controla quais conexões de rede podem chegar aos serviços da máquina. Ele é a primeira barreira contra portas expostas desnecessariamente, mas não substitui autenticação, atualização dos serviços nem políticas de acesso dentro do Kubernetes. Por padrão, bloqueie conexões de entrada e permita apenas o que for necessário.

## Portas publicadas pelo Docker

!!! warning
    Uma porta publicada pelo Docker pode não ser filtrada da maneira esperada pelo UFW ou pelo firewalld.

Com UFW, o Docker pode encaminhar o tráfego publicado antes que ele passe pelas chains normalmente gerenciadas pelo UFW. Com firewalld, o Docker cria uma zona chamada `docker`, cujo target padrão é `ACCEPT`.

Portanto, não considere uma porta publicada pelo Docker protegida apenas porque o firewall do host possui uma política padrão de bloqueio.

Para serviços que só devem ser acessados pelo próprio host, faça bind no loopback:

```yaml
ports:
  - "127.0.0.1:5432:5432"
```

Para serviços que devem ser acessados somente por uma rede específica, faça bind no endereço da interface correspondente:

```yaml
ports:
  - "192.168.1.10:5432:5432"
```

Evite publicar apenas como `5432:5432`, pois isso normalmente faz bind em todas as interfaces disponíveis.

## UFW

Defina as políticas padrão:

> **Executar em:** nó alvo, como `root`.

```bash
ufw default deny incoming
ufw default allow outgoing
```

Antes de habilitar o UFW remotamente, libere o SSH. Informe somente as restrições usadas no ambiente; deixar interface ou CIDR vazios permite o acesso por qualquer interface ou origem, respectivamente.

> **Executar em:** nó alvo, como `root`.

```bash
bash <<'EOF'
set -euo pipefail

read -r -p "Porta TCP do SSH [22]: " SSH_PORT </dev/tty
read -r -p "Interface de entrada (Enter para qualquer): " SSH_INTERFACE </dev/tty
read -r -p "CIDR de origem (Enter para qualquer): " SSH_SOURCE_CIDR </dev/tty

SSH_PORT="${SSH_PORT:-22}"
UFW_RULE=(allow in)

if [[ -n "${SSH_INTERFACE}" ]]; then
  UFW_RULE+=(on "${SSH_INTERFACE}")
fi

if [[ -n "${SSH_SOURCE_CIDR}" ]]; then
  UFW_RULE+=(from "${SSH_SOURCE_CIDR}")
fi

UFW_RULE+=(to any port "${SSH_PORT}" proto tcp)

printf 'Regra que será adicionada: ufw'
printf ' %q' "${UFW_RULE[@]}"
printf '\n'
ufw "${UFW_RULE[@]}"
EOF
```

Nos hosts K3s, libere também a comunicação interna do cluster. Restrinja `K3S_NODE_CIDR` à rede que contém somente os nós; nunca exponha VXLAN/UDP 8472 à Internet.

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

Confira as regras antes de habilitar o firewall:

> **Executar em:** nó alvo, como `root`.

```bash
ufw show added
```

Habilite ou recarregue as regras:

> **Executar em:** nó alvo, como `root`.

```bash
read -r -p "O UFW já está ativo? [s/N]: " UFW_ALREADY_ACTIVE

if [[ "${UFW_ALREADY_ACTIVE,,}" == "s" ]]; then
  ufw reload
else
  ufw enable
fi
```

Valide o estado efetivo e teste uma nova conexão SSH antes de encerrar a sessão original:

> **Executar em:** nó alvo, como `root`.

```bash
ufw status verbose
```

## firewalld

TODO.

