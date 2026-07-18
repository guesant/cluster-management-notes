helm upgrade --install longhorn longhorn \
  --repo https://charts.longhorn.io \
  --version "${LONGHORN_VERSION}" \
  --namespace longhorn-system \
  --create-namespace \
  --wait \
  --timeout 15m
