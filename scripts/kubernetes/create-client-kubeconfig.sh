#!/usr/bin/env bash

set -euo pipefail

for REQUIRED_COMMAND in base64 kubectl openssl tr; do
  if ! command -v "${REQUIRED_COMMAND}" >/dev/null 2>&1; then
    printf 'Comando obrigatório não encontrado: %s\n' "${REQUIRED_COMMAND}" >&2
    exit 1
  fi
done

CURRENT_CONTEXT="$(kubectl config current-context)"
CURRENT_CLUSTER="$(
  kubectl config view \
    --minify \
    --output jsonpath='{.contexts[0].context.cluster}'
)"
CURRENT_SERVER="$(
  kubectl config view \
    --minify \
    --raw \
    --output jsonpath='{.clusters[0].cluster.server}'
)"
CA_DATA="$(
  kubectl config view \
    --flatten \
    --minify \
    --raw \
    --output jsonpath='{.clusters[0].cluster.certificate-authority-data}'
)"

if [[ -z "${CURRENT_CONTEXT}" || -z "${CURRENT_CLUSTER}" || -z "${CURRENT_SERVER}" ]]; then
  printf 'O contexto atual não contém cluster e endpoint válidos.\n' >&2
  exit 1
fi

if [[ -z "${CA_DATA}" ]]; then
  printf 'O kubeconfig atual não forneceu certificate-authority-data após flatten.\n' >&2
  exit 1
fi

printf 'Contexto administrativo atual: %s\n' "${CURRENT_CONTEXT}"
printf 'Cluster atual: %s\n' "${CURRENT_CLUSTER}"

USERNAME=""
while [[ -z "${USERNAME}" ]]; do
  read -r -p "Nome individual da identidade: " USERNAME </dev/tty
done

if [[ ! "${USERNAME}" =~ ^[A-Za-z0-9._@-]+$ ]]; then
  printf 'Use somente letras, números, ponto, sublinhado, @ e hífen no nome.\n' >&2
  exit 1
fi

if [[ "${USERNAME}" == system:* ]]; then
  printf 'O prefixo system: é reservado pelo Kubernetes.\n' >&2
  exit 1
fi

read -r -p "Endpoint acessível da API [${CURRENT_SERVER}]: " API_SERVER </dev/tty
read -r -p "Validade solicitada em segundos [2592000]: " EXPIRATION_SECONDS </dev/tty
read -r -p "Arquivo de saída [${PWD}/kubeconfig-${USERNAME}.yaml]: " OUTPUT_FILE </dev/tty

API_SERVER="${API_SERVER:-${CURRENT_SERVER}}"
EXPIRATION_SECONDS="${EXPIRATION_SECONDS:-2592000}"
OUTPUT_FILE="${OUTPUT_FILE:-${PWD}/kubeconfig-${USERNAME}.yaml}"

if [[ ! "${API_SERVER}" =~ ^https:// ]]; then
  printf 'O endpoint da API deve começar com https://.\n' >&2
  exit 1
fi

if [[ ! "${EXPIRATION_SECONDS}" =~ ^[0-9]+$ ]] || (( EXPIRATION_SECONDS < 600 )); then
  printf 'A validade deve ser um número inteiro de pelo menos 600 segundos.\n' >&2
  exit 1
fi

OUTPUT_DIRECTORY="$(dirname -- "${OUTPUT_FILE}")"
if [[ ! -d "${OUTPUT_DIRECTORY}" ]]; then
  printf 'O diretório de saída não existe: %s\n' "${OUTPUT_DIRECTORY}" >&2
  exit 1
fi

if [[ -e "${OUTPUT_FILE}" ]]; then
  read -r -p "O arquivo já existe. Sobrescrever? [s/N]: " OVERWRITE </dev/tty
  if [[ "${OVERWRITE,,}" != "s" ]]; then
    printf 'Operação cancelada sem alterar o arquivo.\n'
    exit 1
  fi
fi

CSR_ID="$(
  printf '%s' "${USERNAME}" \
    | tr '[:upper:]' '[:lower:]' \
    | tr -cs 'a-z0-9' '-'
)"
CSR_ID="${CSR_ID#-}"
CSR_ID="${CSR_ID%-}"
CSR_NAME="client-${CSR_ID:0:40}-$(date +%s)"
WORK_DIRECTORY="$(mktemp -d)"
CSR_CREATED=false

cleanup() {
  rm -rf -- "${WORK_DIRECTORY}"

  if [[ "${CSR_CREATED}" == true ]]; then
    kubectl delete certificatesigningrequest "${CSR_NAME}" \
      --ignore-not-found \
      >/dev/null 2>&1 || true
  fi
}

trap cleanup EXIT

umask 077
openssl genpkey \
  -algorithm RSA \
  -pkeyopt rsa_keygen_bits:3072 \
  -out "${WORK_DIRECTORY}/client.key" \
  >/dev/null 2>&1

openssl req \
  -new \
  -key "${WORK_DIRECTORY}/client.key" \
  -out "${WORK_DIRECTORY}/client.csr" \
  -subj "/CN=${USERNAME}"

CSR_REQUEST="$(base64 <"${WORK_DIRECTORY}/client.csr" | tr -d '\n')"

kubectl apply -f - <<CSR_MANIFEST
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: ${CSR_NAME}
spec:
  request: ${CSR_REQUEST}
  signerName: kubernetes.io/kube-apiserver-client
  expirationSeconds: ${EXPIRATION_SECONDS}
  usages:
    - client auth
CSR_MANIFEST

CSR_CREATED=true

printf '\nIdentidade solicitada:\n'
kubectl get certificatesigningrequest "${CSR_NAME}" \
  --output jsonpath='{.spec.request}' \
  | base64 --decode \
  | openssl req -noout -subject

read -r -p "Aprovar esta identidade? [s/N]: " APPROVE_IDENTITY </dev/tty
if [[ "${APPROVE_IDENTITY,,}" != "s" ]]; then
  printf 'Solicitação não aprovada.\n'
  exit 1
fi

kubectl certificate approve "${CSR_NAME}"

CERTIFICATE_DATA=""
for ((ATTEMPT = 1; ATTEMPT <= 30; ATTEMPT++)); do
  CERTIFICATE_DATA="$(
    kubectl get certificatesigningrequest "${CSR_NAME}" \
      --output jsonpath='{.status.certificate}'
  )"

  if [[ -n "${CERTIFICATE_DATA}" ]]; then
    break
  fi

  sleep 1
done

if [[ -z "${CERTIFICATE_DATA}" ]]; then
  printf 'O signer não emitiu o certificado dentro do tempo esperado.\n' >&2
  exit 1
fi

printf '%s' "${CERTIFICATE_DATA}" \
  | base64 --decode \
  >"${WORK_DIRECTORY}/client.crt"

printf '%s' "${CA_DATA}" \
  | base64 --decode \
  >"${WORK_DIRECTORY}/cluster-ca.crt"

: >"${OUTPUT_FILE}"

kubectl config set-cluster "${CURRENT_CLUSTER}" \
  --server "${API_SERVER}" \
  --certificate-authority "${WORK_DIRECTORY}/cluster-ca.crt" \
  --embed-certs=true \
  --kubeconfig "${OUTPUT_FILE}" \
  >/dev/null

kubectl config set-credentials "${USERNAME}" \
  --client-certificate "${WORK_DIRECTORY}/client.crt" \
  --client-key "${WORK_DIRECTORY}/client.key" \
  --embed-certs=true \
  --kubeconfig "${OUTPUT_FILE}" \
  >/dev/null

kubectl config set-context "${USERNAME}@${CURRENT_CLUSTER}" \
  --cluster "${CURRENT_CLUSTER}" \
  --user "${USERNAME}" \
  --kubeconfig "${OUTPUT_FILE}" \
  >/dev/null

kubectl config use-context "${USERNAME}@${CURRENT_CLUSTER}" \
  --kubeconfig "${OUTPUT_FILE}" \
  >/dev/null

chmod 0600 "${OUTPUT_FILE}"

printf '\nKubeconfig criado: %s\n' "${OUTPUT_FILE}"
openssl x509 \
  -in "${WORK_DIRECTORY}/client.crt" \
  -noout \
  -subject \
  -dates

printf '\nA identidade ainda precisa receber permissões por RoleBinding ou ClusterRoleBinding.\n'
