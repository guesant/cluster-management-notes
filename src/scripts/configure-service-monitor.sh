SELECTOR_KEY="${SERVICE_LABEL_SELECTOR%%=*}"
SELECTOR_VALUE="${SERVICE_LABEL_SELECTOR#*=}"

kubectl apply -f - <<EOF
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: ${SERVICE_MONITOR_NAME}
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
  endpoints:
    - port: ${METRICS_PORT_NAME}
      path: ${METRICS_PATH}
      interval: 30s
      scrapeTimeout: 10s
EOF
