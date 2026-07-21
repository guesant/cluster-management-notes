kubectl --namespace longhorn-system apply -f - <<EOF
apiVersion: longhorn.io/v1beta2
kind: Volume
metadata:
  name: ${RESTORED_VOLUME_NAME}
  namespace: longhorn-system
spec:
  fromBackup: "$(kubectl --namespace longhorn-system get backups.longhorn.io "${BACKUP_NAME}" -o jsonpath='{.status.url}')"
  numberOfReplicas: 3
  size: "$(kubectl --namespace longhorn-system get backups.longhorn.io "${BACKUP_NAME}" -o jsonpath='{.status.size}')"
EOF
