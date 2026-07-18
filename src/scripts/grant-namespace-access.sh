for REQUIRED_VAR in USERNAME NAMESPACE; do
  if [[ -z "${!REQUIRED_VAR}" ]]; then
    printf '%s não pode ficar vazio.\n' "${REQUIRED_VAR}" >&2
    exit 1
  fi
done

case "${ACCESS_ROLE}" in
  view | edit | admin) ;;
  *)
    printf 'Papel inválido: %s\n' "${ACCESS_ROLE}" >&2
    exit 1
    ;;
esac

BINDING_ID="$(
  printf '%s' "${USERNAME}-${ACCESS_ROLE}" \
    | tr '[:upper:]' '[:lower:]' \
    | tr -cs 'a-z0-9' '-'
)"
BINDING_ID="${BINDING_ID#-}"
BINDING_ID="${BINDING_ID%-}"
BINDING_NAME="${BINDING_ID:-user-access}"

kubectl --namespace "${NAMESPACE}" create rolebinding "${BINDING_NAME}" \
  --clusterrole "${ACCESS_ROLE}" \
  --user "${USERNAME}" \
  --dry-run=client \
  --output yaml \
  | kubectl apply -f -

kubectl auth can-i --list \
  --namespace "${NAMESPACE}" \
  --as "${USERNAME}"
