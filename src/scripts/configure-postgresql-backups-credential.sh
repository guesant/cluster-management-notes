kubectl --namespace "${PG_NAMESPACE}" create secret generic postgresql-backup-credentials \
  --from-literal=ACCESS_KEY_ID="${BACKUP_ACCESS_KEY_ID}" \
  --from-literal=ACCESS_SECRET_KEY="${BACKUP_SECRET_ACCESS_KEY}"
