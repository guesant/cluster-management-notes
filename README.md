# infrastructure-and-cluster-notebook

[![Documentação](https://github.com/guesant/infrastructure-and-cluster-notebook/actions/workflows/docs.yml/badge.svg)](https://github.com/guesant/infrastructure-and-cluster-notebook/actions/workflows/docs.yml)
[![Qualidade dos workflows](https://github.com/guesant/infrastructure-and-cluster-notebook/actions/workflows/actions-quality.yml/badge.svg)](https://github.com/guesant/infrastructure-and-cluster-notebook/actions/workflows/actions-quality.yml)

Minhas anotações sobre como criar e operar clusters K3s de nó único (*single-node*) ou multinó (*multi-node*), reunindo conceitos, melhores práticas, guias passo a passo e scripts reutilizáveis.

## Documentação

O guia completo está publicado em **[guesant.github.io/infrastructure-and-cluster-notebook](https://guesant.github.io/infrastructure-and-cluster-notebook/)**, com busca e navegação por assunto: primeiros passos, fundamentos, segurança dos hosts, Kubernetes/K3s, guias de implantação e operação, e referência.

O escopo do projeto e o [aviso sobre uso de IA na elaboração do conteúdo](https://guesant.github.io/infrastructure-and-cluster-notebook/project/disclaimer/) estão descritos no próprio site, na seção "Projeto".

## Executar localmente

O site é gerado com [Astro Starlight](https://starlight.astro.build/) e roda inteiramente via Docker, sem exigir Node.js instalado na máquina:

```bash
just docs-install   # instala as dependências
just docs-dev        # sobe o servidor de desenvolvimento em http://localhost:4321
```

Detalhes, recipes adicionais (`docs-build`, `docs-preview`) e a alternativa via Dev Container estão em [Executar a documentação localmente](https://guesant.github.io/infrastructure-and-cluster-notebook/contributing/running-locally/).

## Qualidade e atualizações da automação

O workflow [`docs.yml`](.github/workflows/docs.yml) valida Markdown/MDX, verifica links e gera o site a cada alteração; a publicação ocorre após o merge na branch `main` pela API do GitHub Pages (sem branch `gh-pages`).

O workflow [`actions-quality.yml`](.github/workflows/actions-quality.yml) executa o `actionlint` para validar a sintaxe e as expressões dos workflows e o `zizmor` para auditar problemas de segurança. Actions oficiais da organização `actions` usam a tag da versão principal mais recente; actions de terceiros são fixadas por SHA completo. Os checkouts não persistem credenciais.

O [Dependabot](.github/dependabot.yml) verifica semanalmente as actions e as dependências npm. Um cooldown de sete dias evita adotar imediatamente versões recém-publicadas.
