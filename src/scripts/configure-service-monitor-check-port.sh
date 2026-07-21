kubectl --namespace "${APP_NAMESPACE}" get service "${APP_SERVICE_NAME}" -o yaml | grep -A3 ports
