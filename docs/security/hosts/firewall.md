# Firewall

O firewall do host controla quais conexões de rede podem chegar aos serviços da máquina. Ele é a primeira barreira contra portas expostas desnecessariamente, mas não substitui autenticação, atualização dos serviços nem políticas de acesso dentro do Kubernetes. Por padrão, bloqueie conexões de entrada e permita apenas o que for necessário.

As liberações específicas do cluster ficam em [Firewall dos nós K3s](../../k8s/k3s/networking/host-firewall.md). Se o host executar Docker, revise também [Portas publicadas pelo Docker](docker-published-ports.md).

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

!!! note "TODO — firewalld"
    Documentar a configuração equivalente usando firewalld.
