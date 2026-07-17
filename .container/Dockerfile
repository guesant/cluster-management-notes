# syntax=docker/dockerfile:1
# Imagem única do projeto, compartilhada por:
#   - jail-exec.sh          (target: jail)
#   - CI                    (target: ci   — .devcontainer/ci)
#   - VS Code devcontainer  (target: code — .devcontainer/code)
#
# - Bun: gerenciador de pacotes (bun install / bun.lock).
# - Node: runtime de build (astro build) — o runtime do Bun ainda tem
#   incompatibilidades de interop ESM com dependências do Astro; `bun run`
#   usa o node da imagem automaticamente via shebang dos bins.

ARG BUN_VERSION=1.3.14
ARG NODE_VERSION=22.17.0

FROM docker.io/oven/bun:${BUN_VERSION}-slim AS bun

FROM docker.io/library/node:${NODE_VERSION}-bookworm-slim AS jail
COPY --from=bun /usr/local/bin/bun /usr/local/bin/bun
RUN ln -sf /usr/local/bin/bun /usr/local/bin/bunx
WORKDIR /workspace

FROM jail AS ci
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		ca-certificates \
		git \
	&& rm -rf /var/lib/apt/lists/*

FROM ci AS code
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		openssh-client \
	&& rm -rf /var/lib/apt/lists/*
USER node
