kubectl apply -f - <<EOF
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: ${EXTERNAL_SECRET_NAME}
  namespace: ${EXTERNAL_SECRET_NAMESPACE}
spec:
  secretStoreRef:
    name: openbao-backend
    kind: SecretStore
  target:
    name: ${EXTERNAL_SECRET_NAME}
  data:
    - secretKey: value
      remoteRef:
        key: ${REMOTE_KEY}
EOF
