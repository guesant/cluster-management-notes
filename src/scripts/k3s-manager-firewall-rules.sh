if [[ -z "${K3S_NODE_CIDR}" ]]; then
  printf 'O CIDR dos nós não pode ficar vazio.\n' >&2
  exit 1
fi

ufw allow in from "${K3S_NODE_CIDR}" to any port 6443 proto tcp

ufw allow in from "${K3S_NODE_CIDR}" to any port 2379:2380 proto tcp
