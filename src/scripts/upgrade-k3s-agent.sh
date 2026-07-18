if [[ -z "${K3S_VERSION}" ]]; then
  printf 'A versão do K3s não pode ficar vazia.\n' >&2
  exit 1
fi

curl -sfL https://get.k3s.io \
  | INSTALL_K3S_VERSION="${K3S_VERSION}" sh -s - agent
