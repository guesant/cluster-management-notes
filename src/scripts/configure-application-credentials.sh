kubectl apply -f - <<EOF
apiVersion: postgresql.cnpg.io/v1
kind: Database
metadata:
  name: ${APP_DATABASE_NAME}
  namespace: ${PG_NAMESPACE}
spec:
  cluster:
    name: ${PG_CLUSTER_NAME}
  name: ${APP_DATABASE_NAME}
  owner: ${APP_DATABASE_USER}
EOF

kubectl --namespace "${PG_NAMESPACE}" patch cluster "${PG_CLUSTER_NAME}" --type=merge --patch "
spec:
  managed:
    roles:
      - name: ${APP_DATABASE_USER}
        ensure: present
        login: true
        passwordSecret:
          name: ${APP_DATABASE_USER}-credentials
"
