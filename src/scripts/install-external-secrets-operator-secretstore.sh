kubectl apply -f - <<EOF
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: openbao-backend
  namespace: default
spec:
  provider:
    vault:
      server: "${BACKEND_ADDRESS}"
      path: "${KV_PATH}"
      version: v2
      auth:
        kubernetes:
          mountPath: kubernetes
          role: external-secrets
EOF
