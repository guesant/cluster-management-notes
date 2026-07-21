kubectl --namespace monitoring create secret generic alertmanager-slack-webhook \
  --from-literal=url="${SLACK_WEBHOOK_URL}"

kubectl apply -f - <<EOF
apiVersion: monitoring.coreos.com/v1alpha1
kind: AlertmanagerConfig
metadata:
  name: default-routing
  namespace: monitoring
  labels:
    alertmanagerConfig: kube-prometheus-stack
spec:
  route:
    groupBy: ["alertname", "severity"]
    groupWait: 30s
    groupInterval: 5m
    repeatInterval: 4h
    receiver: slack-default
    routes:
      - matchers:
          - name: severity
            value: critical
        receiver: slack-default
        repeatInterval: 1h
  receivers:
    - name: slack-default
      slackConfigs:
        - apiURL:
            name: alertmanager-slack-webhook
            key: url
          channel: "#alerts"
          sendResolved: true
EOF
