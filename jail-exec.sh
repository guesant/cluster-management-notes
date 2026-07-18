#!/usr/bin/env bash

set -euo pipefail

IMAGE="${JAIL_IMAGE:-}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTAINERFILE="${SCRIPT_DIR}/.container/Containerfile"
COMPOSE_FILE="${SCRIPT_DIR}/.container/compose.yml"
LOCAL_IMAGE_TAG="localhost/cluster-management-notes-jail:latest"

ensure_image() {
  if [[ -n "$IMAGE" ]]; then
    return
  fi
  IMAGE="$LOCAL_IMAGE_TAG"
  if [[ -z "${JAIL_REBUILD:-}" ]] && "$@" image inspect "$IMAGE" >/dev/null 2>&1; then
    return
  fi
  "$@" build \
    --file "$CONTAINERFILE" \
    --target jail \
    --tag "$IMAGE" \
    "${SCRIPT_DIR}/.container" >&2
}

if [[ $# -eq 0 ]]; then
  printf 'Uso: %s COMANDO [ARGS...]\n' "$0" >&2
  exit 2
fi

in_container() {
  [[ -n "${container:-}" ]] || [[ -f /.dockerenv ]] || [[ -f /run/.containerenv ]]
}

mode="${JAIL_MODE:-auto}"
if [[ -n "${ALLOW_RUN_COMMANDS_IN_HOST:-}" ]]; then
  mode="bare"
fi

if [[ "$mode" == "auto" ]]; then
  if in_container; then
    mode="bare"
  elif command -v podman >/dev/null 2>&1; then
    mode="podman"
  elif command -v docker >/dev/null 2>&1; then
    mode="docker"
  elif command -v bwrap >/dev/null 2>&1; then
    mode="bwrap"
  else
    printf 'Erro: podman, docker e bwrap não encontrados. Use JAIL_MODE=bare (ou ALLOW_RUN_COMMANDS_IN_HOST=1) para executar no host.\n' >&2
    exit 1
  fi
fi

case "$mode" in
  bare)
    exec "$@"
    ;;
  podman | docker | bwrap)
    if ! command -v "$mode" >/dev/null 2>&1; then
      printf 'Erro: JAIL_MODE=%s, mas o binário "%s" não foi encontrado.\n' "$mode" "$mode" >&2
      exit 1
    fi
    ;;
  compose) ;;
  *)
    printf 'Erro: JAIL_MODE inválido: "%s" (use auto, bare, podman, docker, bwrap ou compose).\n' "$mode" >&2
    exit 2
    ;;
esac

if [[ "$mode" == "compose" ]]; then
  if in_container; then
    exec "$@"
  fi
  if command -v podman >/dev/null 2>&1; then
    compose_cmd=(podman compose)
  elif command -v docker >/dev/null 2>&1; then
    compose_cmd=(docker compose)
    if ! docker info >/dev/null 2>&1; then
      printf 'Aviso: sem acesso ao socket do Docker; tentando com sudo.\n' >&2
      compose_cmd=(sudo docker compose)
    fi
  else
    printf 'Erro: JAIL_MODE=compose exige podman ou docker.\n' >&2
    exit 1
  fi
  compose_cmd+=(--file "$COMPOSE_FILE")
  if [[ -z "$("${compose_cmd[@]}" ps --quiet --status running app 2>/dev/null)" ]]; then
    "${compose_cmd[@]}" up --detach app >&2
  fi
  exec_args=()
  if [[ ! -t 0 || ! -t 1 ]]; then
    exec_args+=(-T)
  fi
  exec "${compose_cmd[@]}" exec "${exec_args[@]}" app "$@"
fi

network="${JAIL_NETWORK:-none}"
if [[ -n "${JAIL_PUBLISH:-}" ]]; then
  network="bridge"
fi

if [[ "$mode" == "bwrap" ]]; then
  bwrap_args=(
    --die-with-parent
    --new-session
    --unshare-all
    --ro-bind /usr /usr
    --proc /proc
    --dev /dev
    --tmpfs /tmp
    --bind "$SCRIPT_DIR" /workspace
    --chdir /workspace
    --clearenv
    --setenv HOME /tmp
    --setenv PATH /usr/local/bin:/usr/bin:/bin
    --setenv BUN_INSTALL_CACHE_DIR /tmp/.bun-cache
    --setenv npm_config_cache /tmp/.npm
    --setenv TERM "${TERM:-xterm}"
  )
  for dir in /bin /lib /lib64 /sbin; do
    if [[ -L "$dir" ]]; then
      bwrap_args+=(--symlink "usr${dir}" "$dir")
    elif [[ -d "$dir" ]]; then
      bwrap_args+=(--ro-bind "$dir" "$dir")
    fi
  done
  if [[ -n "$network" && "$network" != "none" ]]; then
    bwrap_args+=(--share-net)
    [[ -e /etc/resolv.conf ]] && bwrap_args+=(--ro-bind /etc/resolv.conf /etc/resolv.conf)
    [[ -d /etc/ssl ]] && bwrap_args+=(--ro-bind /etc/ssl /etc/ssl)
  fi
  exec bwrap "${bwrap_args[@]}" "$@"
fi

run_args=(
  run --rm
  --cap-drop=ALL
  --security-opt=no-new-privileges
  --read-only
  --tmpfs "/tmp:rw,nosuid,size=1024m"
  --pids-limit=1024
  --memory=4g
  -e HOME=/tmp
  -e BUN_INSTALL_CACHE_DIR=/tmp/.bun-cache
  -e npm_config_cache=/tmp/.npm
  --workdir /workspace
)

if [[ -n "${JAIL_PUBLISH:-}" ]]; then
  run_args+=(-p "127.0.0.1:${JAIL_PUBLISH}:${JAIL_PUBLISH}")
fi
if [[ -z "$network" || "$network" == "none" ]]; then
  run_args+=(--network=none)
fi
if [[ -t 0 && -t 1 ]]; then
  run_args+=(-it)
fi

if [[ "$mode" == "podman" ]]; then
  ensure_image podman
  exec podman "${run_args[@]}" \
    --userns=keep-id \
    --mount "type=bind,src=${SCRIPT_DIR},dst=/workspace" \
    "$IMAGE" "$@"
fi

docker_cmd=(docker)
if ! docker info >/dev/null 2>&1; then
  printf 'Aviso: sem acesso ao socket do Docker; tentando com sudo.\n' >&2
  docker_cmd=(sudo docker)
fi
ensure_image "${docker_cmd[@]}"
exec "${docker_cmd[@]}" "${run_args[@]}" \
  --user "$(id -u):$(id -g)" \
  --mount "type=bind,src=${SCRIPT_DIR},dst=/workspace" \
  "$IMAGE" "$@"
