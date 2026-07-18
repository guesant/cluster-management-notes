#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_ROOT="${NETWORK_POLICY_OUTPUT_DIR:-${SCRIPT_DIR}/manifests}"

usage() {
  cat <<'EOF'
Uso:
  ./generate.sh baseline [namespace]
  ./generate.sh flow [nome] [namespace-origem] [label-origem-chave] [label-origem-valor] [namespace-destino] [label-destino-chave] [label-destino-valor] [porta] [protocolo]
  ./generate.sh traefik [nome] [namespace-destino] [label-destino-chave] [label-destino-valor] [porta] [protocolo]

Modos:
  baseline  Gera default-deny-all e liberação de DNS para um namespace.
  flow      Gera egress na origem e ingress no destino para um fluxo entre workloads já isolados.
  traefik   Gera somente o ingress que permite ao Traefik alcançar um workload publicado.

Os arquivos são gravados em manifests/ e nunca são aplicados automaticamente.
EOF
}

prompt() {
  local variable_name="$1"
  local message="$2"
  local default_value="${3:-}"
  local current_value="${!variable_name:-}"
  local answer

  if [[ -n "${current_value}" ]]; then
    return
  fi

  if [[ -n "${default_value}" ]]; then
    read -r -p "${message} [${default_value}]: " answer </dev/tty
    printf -v "${variable_name}" '%s' "${answer:-${default_value}}"
  else
    read -r -p "${message}: " answer </dev/tty
    printf -v "${variable_name}" '%s' "${answer}"
  fi
}

validate_dns_label() {
  local description="$1"
  local value="$2"

  if (( ${#value} > 63 )) || [[ ! "${value}" =~ ^[a-z0-9]([-a-z0-9]*[a-z0-9])?$ ]]; then
    printf '%s inválido: %s\n' "${description}" "${value}" >&2
    exit 1
  fi
}

validate_label_key() {
  local value="$1"

  if (( ${#value} > 253 )) || [[ ! "${value}" =~ ^([a-z0-9]([-a-z0-9.]*[a-z0-9])?/)?[A-Za-z0-9]([-A-Za-z0-9_.]*[A-Za-z0-9])?$ ]]; then
    printf 'Chave de label inválida: %s\n' "${value}" >&2
    exit 1
  fi
}

validate_label_value() {
  local value="$1"

  if (( ${#value} > 63 )) || [[ ! "${value}" =~ ^[A-Za-z0-9]([-A-Za-z0-9_.]*[A-Za-z0-9])?$ ]]; then
    printf 'Valor de label inválido: %s\n' "${value}" >&2
    exit 1
  fi
}

validate_port() {
  local value="$1"
  local decimal_value

  if [[ ! "${value}" =~ ^[0-9]+$ ]]; then
    printf 'Porta inválida: %s\n' "${value}" >&2
    exit 1
  fi

  decimal_value=$((10#${value}))
  if (( decimal_value < 1 || decimal_value > 65535 )); then
    printf 'Porta inválida: %s\n' "${value}" >&2
    exit 1
  fi
}

validate_protocol() {
  local value="$1"

  case "${value}" in
    TCP|UDP|SCTP) ;;
    *)
      printf 'Protocolo inválido: %s. Use TCP, UDP ou SCTP.\n' "${value}" >&2
      exit 1
      ;;
  esac
}

prepare_file() {
  local path="$1"
  local answer

  install -d -m 0755 "$(dirname -- "${path}")"

  if [[ -e "${path}" ]]; then
    read -r -p "Sobrescrever ${path}? [s/N]: " answer </dev/tty
    if [[ "${answer,,}" != "s" ]]; then
      printf 'Arquivo preservado: %s\n' "${path}" >&2
      exit 1
    fi
  fi
}

generate_baseline() {
  local namespace="${1:-}"
  local deny_file
  local dns_file

  prompt namespace "Namespace que será isolado"
  validate_dns_label "Namespace" "${namespace}"

  deny_file="${OUTPUT_ROOT}/${namespace}/00-default-deny-all.yaml"
  dns_file="${OUTPUT_ROOT}/${namespace}/10-allow-dns.yaml"
  prepare_file "${deny_file}"
  prepare_file "${dns_file}"

  cat >"${deny_file}" <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
  namespace: ${namespace}
spec:
  podSelector: {}
  policyTypes:
    - Ingress
    - Egress
  ingress: []
  egress: []
EOF

  cat >"${dns_file}" <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-dns
  namespace: ${namespace}
spec:
  podSelector: {}
  policyTypes:
    - Egress
  egress:
    - to:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: kube-system
          podSelector:
            matchLabels:
              k8s-app: kube-dns
      ports:
        - protocol: UDP
          port: 53
        - protocol: TCP
          port: 53
EOF

  printf 'Baseline gerada para %s:\n- %s\n- %s\n' "${namespace}" "${deny_file}" "${dns_file}"
}

generate_flow() {
  local flow_name="${1:-}"
  local source_namespace="${2:-}"
  local source_label_key="${3:-}"
  local source_label_value="${4:-}"
  local destination_namespace="${5:-}"
  local destination_label_key="${6:-}"
  local destination_label_value="${7:-}"
  local port="${8:-}"
  local protocol="${9:-}"
  local egress_file
  local ingress_file

  prompt flow_name "Nome curto do fluxo, por exemplo frontend-to-backend"
  prompt source_namespace "Namespace de origem"
  prompt source_label_key "Chave do label dos Pods de origem" "app.kubernetes.io/name"
  prompt source_label_value "Valor do label dos Pods de origem"
  prompt destination_namespace "Namespace de destino"
  prompt destination_label_key "Chave do label dos Pods de destino" "app.kubernetes.io/name"
  prompt destination_label_value "Valor do label dos Pods de destino"
  prompt port "Porta do workload de destino"
  protocol="${protocol^^}"
  prompt protocol "Protocolo" "TCP"
  protocol="${protocol^^}"

  validate_dns_label "Nome do fluxo" "${flow_name}"
  validate_dns_label "Nome da policy de egress" "allow-${flow_name}-egress"
  validate_dns_label "Nome da policy de ingress" "allow-${flow_name}-ingress"
  validate_dns_label "Namespace de origem" "${source_namespace}"
  validate_dns_label "Namespace de destino" "${destination_namespace}"
  validate_label_key "${source_label_key}"
  validate_label_key "${destination_label_key}"
  validate_label_value "${source_label_value}"
  validate_label_value "${destination_label_value}"
  validate_port "${port}"
  validate_protocol "${protocol}"
  port=$((10#${port}))

  egress_file="${OUTPUT_ROOT}/${source_namespace}/20-allow-${flow_name}-egress.yaml"
  ingress_file="${OUTPUT_ROOT}/${destination_namespace}/20-allow-${flow_name}-ingress.yaml"
  prepare_file "${egress_file}"
  prepare_file "${ingress_file}"

  cat >"${egress_file}" <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-${flow_name}-egress
  namespace: ${source_namespace}
spec:
  podSelector:
    matchLabels:
      "${source_label_key}": "${source_label_value}"
  policyTypes:
    - Egress
  egress:
    - to:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: ${destination_namespace}
          podSelector:
            matchLabels:
              "${destination_label_key}": "${destination_label_value}"
      ports:
        - protocol: ${protocol}
          port: ${port}
EOF

  cat >"${ingress_file}" <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-${flow_name}-ingress
  namespace: ${destination_namespace}
spec:
  podSelector:
    matchLabels:
      "${destination_label_key}": "${destination_label_value}"
  policyTypes:
    - Ingress
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: ${source_namespace}
          podSelector:
            matchLabels:
              "${source_label_key}": "${source_label_value}"
      ports:
        - protocol: ${protocol}
          port: ${port}
EOF

  printf 'Fluxo explícito gerado:\n- %s\n- %s\n' "${egress_file}" "${ingress_file}"
}

generate_traefik_ingress() {
  local policy_name="${1:-}"
  local destination_namespace="${2:-}"
  local destination_label_key="${3:-}"
  local destination_label_value="${4:-}"
  local port="${5:-}"
  local protocol="${6:-}"
  local ingress_file

  prompt policy_name "Nome curto da política" "traefik-to-workload"
  prompt destination_namespace "Namespace do workload publicado"
  prompt destination_label_key "Chave do label do workload" "app.kubernetes.io/name"
  prompt destination_label_value "Valor do label do workload"
  prompt port "Porta do workload de destino"
  protocol="${protocol^^}"
  prompt protocol "Protocolo" "TCP"
  protocol="${protocol^^}"

  validate_dns_label "Nome da política" "${policy_name}"
  validate_dns_label "Nome final da policy" "allow-${policy_name}-ingress"
  validate_dns_label "Namespace de destino" "${destination_namespace}"
  validate_label_key "${destination_label_key}"
  validate_label_value "${destination_label_value}"
  validate_port "${port}"
  validate_protocol "${protocol}"
  port=$((10#${port}))

  ingress_file="${OUTPUT_ROOT}/${destination_namespace}/20-allow-${policy_name}-ingress.yaml"
  prepare_file "${ingress_file}"

  cat >"${ingress_file}" <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-${policy_name}-ingress
  namespace: ${destination_namespace}
spec:
  podSelector:
    matchLabels:
      "${destination_label_key}": "${destination_label_value}"
  policyTypes:
    - Ingress
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: kube-system
          podSelector:
            matchLabels:
              app.kubernetes.io/name: traefik
      ports:
        - protocol: ${protocol}
          port: ${port}
EOF

  printf 'Ingress do Traefik gerado:\n- %s\n' "${ingress_file}"
  printf 'O script não isolou nem alterou o egress do Traefik em kube-system.\n'
}

MODE="${1:-}"

if [[ -z "${MODE}" ]]; then
  read -r -p "Modo [baseline/flow/traefik]: " MODE </dev/tty
else
  shift
fi

case "${MODE}" in
  baseline)
    generate_baseline "$@"
    ;;
  flow)
    generate_flow "$@"
    ;;
  traefik)
    generate_traefik_ingress "$@"
    ;;
  help|-h|--help)
    usage
    exit 0
    ;;
  *)
    usage >&2
    exit 1
    ;;
esac

printf '\nRevise os manifests e valide-os antes de commit ou apply.\n'
