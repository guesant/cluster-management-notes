RECOVERY_TARGET_YAML=""
if [[ -n "${RECOVERY_TARGET_TIME}" ]]; then
  RECOVERY_TARGET_YAML="    targetTime: \"${RECOVERY_TARGET_TIME}\""
fi

kubectl apply -f - <<EOF
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: ${PG_RESTORED_NAME}
  namespace: ${PG_NAMESPACE}
spec:
  instances: 1
  storage:
    size: 10Gi
  bootstrap:
    recovery:
      source: original-cluster
      recoveryTarget:
${RECOVERY_TARGET_YAML}
  externalClusters:
    - name: original-cluster
      barmanObjectStore:
        destinationPath: ${BACKUP_DESTINATION}
        s3Credentials:
          accessKeyId:
            name: postgresql-backup-credentials
            key: ACCESS_KEY_ID
          secretAccessKey:
            name: postgresql-backup-credentials
            key: ACCESS_SECRET_KEY
EOF
