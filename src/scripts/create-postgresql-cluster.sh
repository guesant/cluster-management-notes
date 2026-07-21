kubectl create namespace "${PG_NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -f - <<EOF
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: ${PG_CLUSTER_NAME}
  namespace: ${PG_NAMESPACE}
spec:
  instances: ${PG_INSTANCES}
  storage:
    size: ${PG_STORAGE_SIZE}
    storageClass: ${PG_STORAGE_CLASS}
  postgresql:
    parameters:
      max_connections: "100"
EOF
