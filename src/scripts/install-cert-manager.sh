EXTRA_ARGS_JSON="$(printf '["--dns01-recursive-nameservers-only","--dns01-recursive-nameservers=%s"]' \
  "${DNS01_RECURSIVE_NAMESERVERS}")"

helm upgrade --install cert-manager \
  oci://quay.io/jetstack/charts/cert-manager \
  --version "${CERT_MANAGER_VERSION}" \
  --namespace cert-manager \
  --create-namespace \
  --set crds.enabled=true \
  --set config.gatewayAPI.enabled=true \
  --set-json "extraArgs=${EXTRA_ARGS_JSON}" \
  --wait \
  --timeout 10m
