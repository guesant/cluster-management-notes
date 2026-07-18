if [[ -z "${K3S_NODE_CIDR}" ]]; then
  printf 'O CIDR dos nós não pode ficar vazio.\n' >&2
  exit 1
fi

ufw allow in from "${K3S_NODE_CIDR}" to any port 8472 proto udp
ufw allow in from "${K3S_NODE_CIDR}" to any port 10250 proto tcp

ufw allow in from "${K3S_POD_CIDR}"
ufw allow in from "${K3S_SERVICE_CIDR}"
