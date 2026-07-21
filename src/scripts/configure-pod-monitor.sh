SELECTOR_KEY="${POD_LABEL_SELECTOR%%=*}"
SELECTOR_VALUE="${POD_LABEL_SELECTOR#*=}"

kubectl apply -f - <<EOF
apiVersion: monitoring.coreos.com/v1
kind: PodMonitor
metadata:
  name: ${POD_MONITOR_NAME}
  namespace: monitoring
  labels:
    release: kube-prometheus-stack
spec:
  namespaceSelector:
    matchNames:
      - ${APP_NAMESPACE}
  selector:
    matchLabels:
      ${SELECTOR_KEY}: ${SELECTOR_VALUE}
  podMetricsEndpoints:
    - port: ${METRICS_PORT}
      path: ${METRICS_PATH}
      interval: 30s
EOF
