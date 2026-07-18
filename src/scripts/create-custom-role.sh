for REQUIRED_VAR in USERNAME NAMESPACE ROLE_NAME; do
  if [[ -z "${!REQUIRED_VAR}" ]]; then
    printf '%s não pode ficar vazio.\n' "${REQUIRED_VAR}" >&2
    exit 1
  fi
done

kubectl --namespace "${NAMESPACE}" create role "${ROLE_NAME}" \
  --resource "${RESOURCES}" \
  --verb "${VERBS}" \
  --dry-run=client \
  --output yaml \
  | kubectl apply -f -

BINDING_ID="$(
  printf '%s' "${USERNAME}-${ROLE_NAME}" \
    | tr '[:upper:]' '[:lower:]' \
    | tr -cs 'a-z0-9' '-'
)"
BINDING_ID="${BINDING_ID#-}"
BINDING_ID="${BINDING_ID%-}"
BINDING_NAME="${BINDING_ID:-custom-access}"

kubectl --namespace "${NAMESPACE}" create rolebinding "${BINDING_NAME}" \
  --role "${ROLE_NAME}" \
  --user "${USERNAME}" \
  --dry-run=client \
  --output yaml \
  | kubectl apply -f -

kubectl auth can-i --list \
  --namespace "${NAMESPACE}" \
  --as "${USERNAME}"
