set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

compose_file := ".container/compose.yml"

default:
    @just --list

_compose *args:
    if command -v podman >/dev/null 2>&1; then \
        podman compose --file {{compose_file}} {{args}}; \
    elif docker info >/dev/null 2>&1; then \
        docker compose --file {{compose_file}} {{args}}; \
    else \
        echo "Aviso: sem acesso ao socket do Docker; tentando com sudo." >&2; \
        sudo docker compose --file {{compose_file}} {{args}}; \
    fi

up:
    just _compose up --detach app

down:
    just _compose down

shell: up
    just _compose exec app bash

start:
    if [[ -n "${container:-}" || -f /.dockerenv || -f /run/.containerenv ]]; then \
        test -d node_modules || bun install; \
        bun run dev -- --host 0.0.0.0; \
    else \
        just up; \
        just _compose exec app bash -lc 'test -d node_modules || bun install; bun run dev -- --host 0.0.0.0'; \
    fi
