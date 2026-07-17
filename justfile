set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

docs_node_image := "node:lts-alpine"

default:
    @just --list

# Instala as dependências do site de documentação (Astro Starlight)
docs-install:
    docker run --rm \
        --user "$(id -u):$(id -g)" \
        --env HOME=/tmp \
        --volume "${PWD}:/workspace" \
        --workdir /workspace \
        {{docs_node_image}} \
        npm ci

# Sobe o servidor de desenvolvimento em http://localhost:4321
docs-dev:
    test -d node_modules || just docs-install
    docker run --rm \
        --user "$(id -u):$(id -g)" \
        --env HOME=/tmp \
        --publish 4321:4321 \
        --volume "${PWD}:/workspace" \
        --workdir /workspace \
        {{docs_node_image}} \
        npm run dev -- --host 0.0.0.0

# Gera o build de produção em dist/, falhando em links quebrados ou frontmatter ausente
docs-build:
    test -d node_modules || just docs-install
    docker run --rm \
        --user "$(id -u):$(id -g)" \
        --env HOME=/tmp \
        --volume "${PWD}:/workspace" \
        --workdir /workspace \
        {{docs_node_image}} \
        npm run build

# Serve o build de produção gerado por docs-build em http://localhost:4321
docs-preview:
    test -d node_modules || just docs-install
    docker run --rm \
        --user "$(id -u):$(id -g)" \
        --env HOME=/tmp \
        --publish 4321:4321 \
        --volume "${PWD}:/workspace" \
        --workdir /workspace \
        {{docs_node_image}} \
        npm run preview -- --host 0.0.0.0
