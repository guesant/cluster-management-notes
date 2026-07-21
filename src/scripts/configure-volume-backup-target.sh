kubectl --namespace longhorn-system patch settings.longhorn.io backup-target --type=merge \
  --patch "{\"value\": \"${BACKUP_TARGET_URL}\"}"

kubectl --namespace longhorn-system patch settings.longhorn.io backup-target-credential-secret --type=merge \
  --patch '{"value": "longhorn-backup-secret"}'
