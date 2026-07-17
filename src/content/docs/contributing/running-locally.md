---
title: Executar a documentação localmente
description: Como rodar, validar e visualizar o site Astro Starlight sem instalar Node.js na máquina.
sidebar:
  order: 1
---

O site é gerado com [Astro](https://astro.build/) e [Starlight](https://starlight.astro.build/).
Assim como o restante do projeto, a execução local não exige instalar Node.js na máquina: os
comandos abaixo rodam tudo dentro de um container.

## Via `just`

O [`justfile`](https://github.com/guesant/cluster-management-notes/blob/main/justfile) na raiz do
repositório expõe as recipes usadas no dia a dia:

```bash
# Instala as dependências (necessário antes das outras recipes)
just docs-install

# Sobe o servidor de desenvolvimento em http://localhost:4321 com live reload
just docs-dev

# Gera o build de produção em dist/, falhando em links quebrados ou frontmatter ausente
just docs-build

# Serve o build de produção gerado por docs-build em http://localhost:4321
just docs-preview
```

Cada recipe roda `docker run` com a imagem oficial `node:lts-alpine`, montando a raiz do
repositório no container — nenhuma dependência é instalada na máquina host além do Docker.

## Via Dev Container

Para quem prefere abrir o projeto num ambiente já pronto (VS Code Dev Containers ou GitHub
Codespaces), o repositório inclui um
[`.devcontainer/devcontainer.json`](https://github.com/guesant/cluster-management-notes/blob/main/.devcontainer/devcontainer.json).
Ao abrir o repositório no Dev Container, as dependências são instaladas automaticamente
(`npm ci`) e a porta `4321` já fica encaminhada — basta rodar `npm run dev` dentro do container.

## Estrutura do conteúdo

- O conteúdo das páginas fica em `src/content/docs/`, organizado por categoria (uma pasta por
  seção da barra lateral).
- Componentes reutilizáveis ficam em `src/components/`.
- A navegação da barra lateral é definida em `astro.config.mjs`; a maioria das seções usa
  `autogenerate`, então basta adicionar um arquivo `.md`/`.mdx` na pasta correta para que ele
  apareça automaticamente, na ordem definida pelo campo `sidebar.order` do frontmatter.

## Antes de abrir um PR

Rode o build (`just docs-build`) e, se aplicável, o lint e a verificação de links descritos no
workflow [`Documentação`](https://github.com/guesant/cluster-management-notes/blob/main/.github/workflows/docs.yml) —
os mesmos passos rodam automaticamente no CI a cada push ou pull request que altere a
documentação.
