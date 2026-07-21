kubectl --namespace longhorn-system patch volumes.longhorn.io "${VOLUME_NAME}" --type=merge \
  --patch '{"spec": {"snapshotDataIntegrity": "fast-check"}}'

kubectl --namespace longhorn-system create -f - <<EOF
apiVersion: longhorn.io/v1beta2
kind: Backup
metadata:
  name: ${VOLUME_NAME}-manual-$(date +%Y%m%d)
  namespace: longhorn-system
spec:
  snapshotName: ""
  volumeName: ${VOLUME_NAME}
EOF
