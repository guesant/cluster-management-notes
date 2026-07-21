helm upgrade --install external-secrets external-secrets \
  --repo https://charts.external-secrets.io \
  --version "${ESO_VERSION}" \
  --namespace external-secrets \
  --create-namespace \
  --set installCRDs=true
