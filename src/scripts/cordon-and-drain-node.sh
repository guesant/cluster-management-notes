kubectl cordon "${K3S_NODE_NAME}"
kubectl drain "${K3S_NODE_NAME}" \
  --ignore-daemonsets \
  --delete-emptydir-data
