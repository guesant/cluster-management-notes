---
title: Snippets reutilizáveis
sidebar:
  order: 3
---

Fragmentos pequenos de código (shell, YAML, configurações) prontos para copiar em contextos específicos. A diferença para uma recipe de [comando](../commands/) é que uma recipe descreve um processo (um ou dois comandos com contexto de quando usar); um snippet é um bloco de código que se encaixa dentro de uma estrutura maior já existente, como um manifesto ou um script.

## Por linguagem ou formato

- [Bash](../bash/): funções, loops, padrões de tratamento de erro.
- [Docker Compose](../docker-compose/): serviços, redes, volumes comuns.
- [Kubernetes](../kubernetes/): manifests, labels, selectors.

As categorias a seguir estão planejadas (Fase 7 do plano de conteúdo interno, `.todo/phase-7-toolbox.md`, fora do site publicado), mas ainda não foram escritas: Fish shell (aliases, funções, configuração), Systemd (units, timers, targets), Helm (`values.yaml`, templates, Charts), Kustomize (patches, overlays, bases), Argo CD (applications, sync policies), Traefik (middleware, services, rotas), Prometheus (scrape configs, regras de alerta), GitHub Actions (workflows, jobs, steps) e GitLab CI (pipelines, jobs, stages).
