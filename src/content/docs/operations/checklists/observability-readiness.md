---
title: Prontidão de observabilidade
sidebar:
  order: 4
---

> **Para quem é:** quem precisa confirmar se o cluster e as aplicações têm observabilidade suficiente antes de depender delas em produção.

Checklist especializado referenciado pelo [checklist central](../cluster-operational-checklist/). Detalha os itens de observabilidade descritos em [observabilidade e alertas](../../observability/observability-and-alerting/).

- [ ] Métricas do cluster (control plane, componentes de sistema) coletadas
  - Explicação e configuração: [observabilidade e alertas](../../observability/observability-and-alerting/)
  - Verificação: `kubectl --namespace kube-system get pods -l app.kubernetes.io/name=metrics-server`
  - Frequência: contínua; revisar mensalmente

- [ ] Métricas dos nós (CPU, memória, disco, rede) coletadas
  - Explicação e configuração: [templates de monitoring](../../../guides/blueprints/k3s-single-node-gitops/templates/)
  - Verificação: `kubectl top nodes`
  - Frequência: contínua

- [ ] Métricas das aplicações expostas e coletadas
  - Explicação e configuração: [prontidão de workloads](../application-readiness/)
  - Verificação: revisão manual dos targets no Prometheus (`/targets`)
  - Frequência: ao adicionar um novo workload

- [ ] Logs centralizados fora do ciclo de vida dos Pods
  - Explicação e configuração: [observabilidade e alertas](../../observability/observability-and-alerting/)
  - Verificação: consultar um log de um Pod já removido no backend de logging
  - Frequência: mensal

- [ ] Dashboards cobrindo disponibilidade, erro, latência e capacidade
  - Explicação e configuração: [templates de monitoring](../../../guides/blueprints/k3s-single-node-gitops/templates/)
  - Verificação: revisão manual dos dashboards do Grafana
  - Frequência: mensal

- [ ] Alertas configurados para as condições críticas do cluster
  - Explicação e configuração: [observabilidade e alertas](../../observability/observability-and-alerting/)
  - Verificação: `kubectl --namespace monitoring get prometheusrules`
  - Frequência: mensal

- [ ] Retenção de métricas e logs definida e compatível com a capacidade
  - Explicação e configuração: [templates de monitoring](../../../guides/blueprints/k3s-single-node-gitops/templates/)
  - Verificação: revisão manual de `retention` no `values.yaml` do Prometheus
  - Frequência: trimestral

- [ ] Monitoramento externo capaz de detectar indisponibilidade do próprio cluster
  - Explicação: [observabilidade e alertas](../../observability/observability-and-alerting/)
  - Verificação: teste manual, desligar o acesso ao Prometheus e confirmar que um monitor externo detecta
  - Frequência: trimestral

- [ ] Capacidade (CPU/memória/disco/rede) com limites operacionais conhecidos
  - Explicação e configuração: [revisão de capacidade de disco](../../maintenance/disk-capacity-review/)
  - Verificação: `kubectl top nodes` e `df --human`
  - Frequência: mensal

- [ ] Certificados monitorados quanto ao vencimento
  - Explicação e configuração: [revisão de certificados](../../maintenance/certificate-review/)
  - Verificação: `kubectl get certificates --all-namespaces`
  - Frequência: semanal

- [ ] Capacidade de volumes persistentes monitorada
  - Explicação e configuração: [Longhorn](../../../guides/tasks/storage/install-longhorn/)
  - Verificação: `kubectl --namespace longhorn-system get nodes.longhorn.io -o wide`
  - Frequência: mensal

## Fontes e leitura adicional

- [Observabilidade no Kubernetes](https://kubernetes.io/docs/concepts/cluster-administration/observability/): organiza métricas, logs e traces usados para compreender o estado do sistema.
