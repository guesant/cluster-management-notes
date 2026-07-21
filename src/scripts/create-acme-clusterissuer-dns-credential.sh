kubectl --namespace cert-manager create secret generic dns-provider-credentials \
  --from-literal=api-token="${DNS_PROVIDER_TOKEN}"
