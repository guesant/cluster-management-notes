# syntax=docker/dockerfile:1
# Imagem única do projeto, compartilhada por:
#   - jail-exec.sh          (target: jail)
#   - CI                    (target: ci   — .devcontainer/ci)
#   - VS Code devcontainer  (target: code — .devcontainer/code)
#
# Bun é gerenciador de pacotes e runtime. O symlink node -> bun faz os bins
# com shebang `#!/usr/bin/env node` (astro etc.) rodarem no runtime do Bun.

ARG BUN_VERSION=1.3.14

FROM docker.io/oven/bun:${BUN_VERSION}-slim AS jail
RUN ln -sf /usr/local/bin/bun /usr/local/bin/node
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
USER bun
