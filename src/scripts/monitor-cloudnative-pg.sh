kubectl apply -f - <<EOF
apiVersion: monitoring.coreos.com/v1
kind: PodMonitor
metadata:
  name: ${PG_CLUSTER_NAME}
  namespace: monitoring
  labels:
    release: kube-prometheus-stack
spec:
  namespaceSelector:
    matchNames:
      - ${PG_NAMESPACE}
  selector:
    matchLabels:
      cnpg.io/cluster: ${PG_CLUSTER_NAME}
  podMetricsEndpoints:
    - port: metrics
      interval: 30s
EOF
