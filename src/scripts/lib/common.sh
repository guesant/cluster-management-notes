#!/bin/bash
# Biblioteca de funções reutilizáveis para scripts
# Uso: source "$(dirname "$0")/../lib/common.sh"

set -euo pipefail

# Validar que comando existe
require_command() {
  local cmd="$1"
  if ! command -v "$cmd" &>/dev/null; then
    echo "Erro: comando '$cmd' não encontrado. Instale antes de continuar." >&2
    return 1
  fi
}

# Validar que variável está definida e não vazia
require_var() {
  local var_name="$1"
  local var_value="${!var_name:-}"

  if [[ -z "$var_value" ]]; then
    echo "Erro: variável '$var_name' não definida ou vazia." >&2
    return 1
  fi
}

# Validar SO (Debian/Ubuntu)
require_debian_like() {
  if ! grep -qi "debian\|ubuntu" /etc/os-release; then
    echo "Erro: este script requer Debian ou Ubuntu." >&2
    return 1
  fi
}

# Validar que código anterior não falhou
check_previous_exit() {
  local exit_code=$1
  local operation="${2:-operação anterior}"

  if [[ $exit_code -ne 0 ]]; then
    echo "Erro: $operation falhou (código: $exit_code)" >&2
    return $exit_code
  fi
}

# Download com validação SHA256
download_and_verify() {
  local url="$1"
  local expected_sha="$2"
  local output_file="${3:-.}"

  require_command curl

  echo "Downloading: $url"
  if ! curl -sSfL "$url" -o "$output_file"; then
    echo "Erro: falha no download de $url" >&2
    return 1
  fi

  echo "Verificando SHA256..."
  local actual_sha
  actual_sha=$(sha256sum "$output_file" | awk '{print $1}')

  if [[ "$actual_sha" != "$expected_sha" ]]; then
    echo "Erro: SHA256 não corresponde!" >&2
    echo "  Esperado:  $expected_sha" >&2
    echo "  Obtido:    $actual_sha" >&2
    return 1
  fi

  echo "✓ Verificação OK"
}

# Executar comando, capturar saída, mostrar erro se falhar
run_and_check() {
  local cmd_desc="$1"
  shift  # resto é o comando

  echo "→ $cmd_desc"
  if ! output=$("$@" 2>&1); then
    echo "Erro: $cmd_desc falhou" >&2
    echo "$output" >&2
    return 1
  fi
  echo "$output"
}

# Cleanup com trap para temporários
setup_cleanup_trap() {
  local tmpdir="$1"
  trap "rm -rf '$tmpdir'" EXIT
}

# Confirmar ação destrutiva
confirm_destructive() {
  local action="$1"
  local target="${2:-sistema}"

  echo ""
  echo "⚠️  AVISO: Esta ação é destrutiva!"
  echo "Ação: $action"
  echo "Alvo: $target"
  echo ""

  read -r -p "Tem certeza? Digite 'sim' para confirmar: " confirmation

  if [[ "$confirmation" != "sim" ]]; then
    echo "Operação cancelada." >&2
    return 1
  fi
}

# Logging estruturado
log_info() {
  echo "[INFO] $(date +'%Y-%m-%d %H:%M:%S') - $*"
}

log_error() {
  echo "[ERROR] $(date +'%Y-%m-%d %H:%M:%S') - $*" >&2
}

log_success() {
  echo "[OK] $(date +'%Y-%m-%d %H:%M:%S') - $*"
}

# Esperar até que condição seja verdadeira (com timeout)
wait_for() {
  local condition="$1"
  local timeout="${2:-30}"
  local interval="${3:-1}"

  local elapsed=0
  while [[ $elapsed -lt $timeout ]]; do
    if eval "$condition"; then
      return 0
    fi
    sleep "$interval"
    ((elapsed += interval))
  done

  log_error "Timeout aguardando: $condition"
  return 1
}

# Detectar arquitetura
get_architecture() {
  case "$(uname -m)" in
    x86_64)  echo "amd64" ;;
    aarch64) echo "arm64" ;;
    *)       echo "unknown" ;;
  esac
}

# Detectar SO
get_distro() {
  if grep -qi "ubuntu" /etc/os-release; then
    echo "ubuntu"
  elif grep -qi "debian" /etc/os-release; then
    echo "debian"
  else
    echo "unknown"
  fi
}

# Obter versão SO
get_os_version() {
  grep "VERSION_ID" /etc/os-release | cut -d'"' -f2
}
