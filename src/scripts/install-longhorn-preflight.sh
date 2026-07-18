longhornctl \
  --kubeconfig "${KUBECONFIG:-$HOME/.kube/config}" \
  --image "longhornio/longhorn-cli:${LONGHORN_VERSION}" \
  install preflight

longhornctl check preflight
