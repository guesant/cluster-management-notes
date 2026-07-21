kubectl --namespace "${PG_NAMESPACE}" patch cluster "${PG_CLUSTER_NAME}" --type=merge --patch "
spec:
  backup:
    barmanObjectStore:
      destinationPath: ${BACKUP_DESTINATION}
      s3Credentials:
        accessKeyId:
          name: postgresql-backup-credentials
          key: ACCESS_KEY_ID
        secretAccessKey:
          name: postgresql-backup-credentials
          key: ACCESS_SECRET_KEY
      wal:
        compression: gzip
    retentionPolicy: 30d
"

kubectl apply -f - <<EOF
apiVersion: postgresql.cnpg.io/v1
kind: ScheduledBackup
metadata:
  name: ${PG_CLUSTER_NAME}-daily
  namespace: ${PG_NAMESPACE}
spec:
  schedule: "0 2 * * *"
  backupOwnerReference: self
  cluster:
    name: ${PG_CLUSTER_NAME}
EOF
