# cluster-management-notes

[![Documentação](https://github.com/guesant/cluster-management-notes/actions/workflows/docs.yml/badge.svg)](https://github.com/guesant/cluster-management-notes/actions/workflows/docs.yml)
[![Qualidade dos workflows](https://github.com/guesant/cluster-management-notes/actions/workflows/actions-quality.yml/badge.svg)](https://github.com/guesant/cluster-management-notes/actions/workflows/actions-quality.yml)

Minhas anotações sobre como criar e operar clusters K3s de nó único (*single-node*) ou multinó (*multi-node*), reunindo conceitos, melhores práticas, guias passo a passo e scripts reutilizáveis.

## Documentação

- [Site publicado](https://guesant.github.io/cluster-management-notes/)
- [Início do guia](docs/index.md)
- [Ensaio: cluster K3s](docs/guides/k3s.md)
- [Guia de operação contínua](docs/guides/operations.md)
- [Prontidão de workloads](docs/k8s/workloads/production-readiness.md)
- [Observabilidade e alertas](docs/operations/observability-and-alerting.md)
- [Backup e recuperação](docs/operations/backup-and-recovery.md)
- [Runbook de manutenção e mudanças](docs/operations/maintenance-runbook.md)
- [Fundamentos](docs/k8s/concepts.md)
- [Segurança dos hosts](docs/security/hosts/firewall.md)
- [Rede Kubernetes](docs/k8s/networking/gateway-api-and-traefik.md)
- [Segurança e acesso](docs/k8s/security/remote-access.md)
- [Extensões](docs/k8s/extensions/cert-manager.md)
- [GitOps com Argo CD](docs/strategies/deployment/argo-cd.md)
- [Gestão de segredos](docs/strategies/secrets/infisical.md)
- [Referência](docs/reference/conventions.md)
- [Ferramentas e catálogos do ecossistema](docs/reference/tools-and-resources.md)

## Validar a documentação com Docker

O build usa a imagem definida em [`.github/docker/mkdocs/Dockerfile`](.github/docker/mkdocs/Dockerfile) e não instala dependências na máquina. Para validar e gerar o site em `site/`:

```bash
just docs-build
```

Para visualizar o site em `http://localhost:8000`:

```bash
just docs-serve
```

O deploy ocorre pelo workflow [`.github/workflows/docs.yml`](.github/workflows/docs.yml) após alterações na documentação entrarem na branch `main`.

Antes da primeira publicação, selecione **GitHub Actions** em **Settings → Pages → Build and deployment → Source**. O workflow não usa uma branch `gh-pages`: ele envia e publica o artefato estático pela API do GitHub Pages.

## Qualidade e atualizações da automação

O workflow [`.github/workflows/actions-quality.yml`](.github/workflows/actions-quality.yml) executa o `actionlint` para validar a sintaxe e as expressões dos workflows e o `zizmor` para auditar problemas de segurança. Actions oficiais da organização `actions` usam a tag da versão principal mais recente; actions de terceiros são fixadas por SHA completo. Os checkouts não persistem credenciais.

O [Dependabot](.github/dependabot.yml) verifica semanalmente as actions e a imagem Docker usada pelo MkDocs. Um cooldown de sete dias evita adotar imediatamente versões recém-publicadas.
