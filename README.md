# infrastructure-and-cluster-notebook

[![Documentação](https://github.com/guesant/infrastructure-and-cluster-notebook/actions/workflows/docs.yml/badge.svg)](https://github.com/guesant/infrastructure-and-cluster-notebook/actions/workflows/docs.yml)
[![Qualidade dos workflows](https://github.com/guesant/infrastructure-and-cluster-notebook/actions/workflows/actions-quality.yml/badge.svg)](https://github.com/guesant/infrastructure-and-cluster-notebook/actions/workflows/actions-quality.yml)

Minhas anotações sobre infraestrutura, containers e clusters: conceitos, blueprints, guias passo a passo, operação e catálogo de ferramentas. O foco atual e mais completo é criar e operar clusters K3s de nó único (*single-node*) ou multinó (*multi-node*); o restante do escopo (Docker Swarm, outras distribuições Kubernetes, mais ferramentas) está em expansão.

## Documentação

O guia completo está publicado em **[guesant.github.io/infrastructure-and-cluster-notebook](https://guesant.github.io/infrastructure-and-cluster-notebook/)**, com busca e navegação por seção: primeiros passos, aprender (conceitos e comparações), guias (blueprints e task guides), operação, toolbox, tecnologias, recursos e referência.

O escopo do projeto, as [decisões arquiteturais](https://guesant.github.io/infrastructure-and-cluster-notebook/project/decisions/) e o [aviso sobre uso de IA na elaboração do conteúdo](https://guesant.github.io/infrastructure-and-cluster-notebook/project/disclaimer/) estão descritos no próprio site, na seção "Projeto".

## Executar localmente

O site é gerado com [Astro Starlight](https://starlight.astro.build/) e [Bun](https://bun.sh/), e roda inteiramente em container via [`jail-exec.sh`](jail-exec.sh), sem exigir Node.js/Bun instalados na máquina:

```bash
JAIL_NETWORK=1 ./jail-exec.sh bun install                          # instala as dependências
JAIL_PUBLISH=4321 ./jail-exec.sh bun run dev -- --host 0.0.0.0      # servidor de desenvolvimento em http://localhost:4321
```

Detalhes, comandos adicionais (`bun run build`, `bun run lint`) e a alternativa via Dev Container estão em [Executar a documentação localmente](https://guesant.github.io/infrastructure-and-cluster-notebook/contributing/local-development/).

## Qualidade e atualizações da automação

O workflow [`docs.yml`](.github/workflows/docs.yml) valida Markdown/MDX, verifica links quebrados (`lychee`) e gera o site a cada alteração; a publicação ocorre após o merge na branch `main` pela API do GitHub Pages (sem branch `gh-pages`).

O workflow [`actions-quality.yml`](.github/workflows/actions-quality.yml) executa o `actionlint` para validar a sintaxe e as expressões dos workflows e o `zizmor` para auditar problemas de segurança. Actions oficiais da organização `actions` usam a tag da versão principal mais recente; actions de terceiros são fixadas por SHA completo. Os checkouts não persistem credenciais.

O [Dependabot](.github/dependabot.yml) verifica semanalmente as actions e as dependências Bun. Um cooldown de sete dias evita adotar imediatamente versões recém-publicadas.
