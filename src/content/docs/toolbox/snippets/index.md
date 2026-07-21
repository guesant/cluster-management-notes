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
- [Systemd](../systemd/): units de serviço e timer mínimas, limites de recursos, drop-ins.
- [Helm](../helm/): `values.yaml` mínimo e o padrão de rota opt-in usado pelos charts deste notebook.
- [Argo CD](../argocd/): `Application` raiz (App-of-Apps) e `Application` de componente.
- [Traefik e Gateway API](../traefik/): `GatewayClass`, `Gateway` com TLS e `HTTPRoute` por listener.

Fish shell, Kustomize, Prometheus, GitHub Actions e GitLab CI foram avaliados e descartados como categorias próprias: nenhum guia deste notebook depende de um snippet dedicado a eles. Fish shell e GitLab CI não são citados em nenhuma página. Kustomize aparece só como uma alternativa mencionada de passagem em [usar SOPS com o Argo CD](../../../guides/tasks/secrets/use-sops-with-argocd/), sem um patch ou overlay real para exemplificar. GitHub Actions aparece apenas como link para os workflows deste próprio repositório (fora do escopo de um snippet genérico reutilizável). Prometheus já tem cobertura melhor do que um snippet estático ofereceria: scrape config via `PodMonitor`/`ServiceMonitor` são gerados interativamente em [configurar um PodMonitor](../../../guides/tasks/observability/configure-pod-monitor/) e [configurar um ServiceMonitor](../../../guides/tasks/observability/configure-service-monitor/), e um `PrometheusRule` mínimo já está em [observabilidade e alertas](../../../operations/observability/observability-and-alerting/#alerta-mínimo-com-prometheusrule).
