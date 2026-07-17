if (( EUID != 0 )); then
  printf 'Execute este bloco em um shell root aberto com sudo -i.\n' >&2
  exit 1
fi

for REQUIRED_VAR in K3S_NODE_IP K3S_NODE_NAME K3S_API_HOST; do
  if [[ -z "${!REQUIRED_VAR}" ]]; then
    printf '%s não pode ficar vazio.\n' "${REQUIRED_VAR}" >&2
    exit 1
  fi
done

if [[ -z "${K3S_TOKEN}" ]]; then
  K3S_TOKEN="$(openssl rand -hex 64)"
  printf '\nToken gerado; guarde-o agora em um gerenciador de segredos:\n%s\n\n' \
    "${K3S_TOKEN}" \
    >/dev/tty

  read -r -p "O token foi guardado com segurança? [s/N]: " TOKEN_SAVED </dev/tty
  if [[ "${TOKEN_SAVED,,}" != "s" ]]; then
    printf 'Instalação cancelada antes de alterar o host.\n' >&2
    exit 1
  fi
fi

install -d -o root -g root -m 0700 /etc/rancher/k3s

umask 077
cat >/etc/rancher/k3s/config.yaml <<K3S_CONFIG
token: "${K3S_TOKEN}"
node-ip: "${K3S_NODE_IP}"
node-name: "${K3S_NODE_NAME}"
tls-san:
  - "${K3S_API_HOST}"
  - "${K3S_NODE_IP}"
disable:
  - local-storage
secrets-encryption: true
cluster-init: true
K3S_CONFIG

chmod 0600 /etc/rancher/k3s/config.yaml

curl -sfL https://get.k3s.io \
  | INSTALL_K3S_VERSION="${K3S_VERSION}" sh -s - server

export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

systemctl --no-pager --full status k3s
kubectl wait --for=condition=Ready "node/${K3S_NODE_NAME}" --timeout=180s
kubectl get nodes -o wide
kubectl get pods --all-namespaces
