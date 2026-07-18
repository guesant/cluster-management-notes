if [[ -z "${USERNAME}" ]]; then
  printf 'USERNAME não pode ficar vazio.\n' >&2
  exit 1
fi

BINDING_ID="$(
  printf '%s' "${USERNAME}" \
    | tr '[:upper:]' '[:lower:]' \
    | tr -cs 'a-z0-9' '-'
)"
BINDING_ID="${BINDING_ID#-}"
BINDING_ID="${BINDING_ID%-}"
BINDING_NAME="${BINDING_ID:-user}-cluster-admin"

kubectl create clusterrolebinding "${BINDING_NAME}" \
  --clusterrole cluster-admin \
  --user "${USERNAME}" \
  --dry-run=client \
  --output yaml \
  | kubectl apply -f -

kubectl auth can-i '*' '*' \
  --all-namespaces \
  --as "${USERNAME}"
