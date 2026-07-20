---
title: Prontidão para produção
sidebar:
  order: 6
---

> **Para quem é:** quem precisa de uma visão consolidada, por cenário, antes de considerar um cluster ou workload pronto para produção.

Este checklist consolida os itens relevantes dos checklists especializados para o cenário "colocar algo em produção pela primeira vez". Ele não substitui as páginas detalhadas: cada linha aponta para o checklist completo correspondente.

- [ ] [Segurança do host](../host-security/): todos os itens aplicáveis ao host de produção.
- [ ] [Segurança do cluster](../cluster-security/): RBAC, Pod Security, NetworkPolicies e origem de imagens revisados.
- [ ] [Prontidão de workloads](../application-readiness/): probes, recursos, PDB e rollout validados para cada workload que vai a produção.
- [ ] [Prontidão de observabilidade](../observability-readiness/): métricas, logs, dashboards e alertas funcionando antes do tráfego real chegar.
- [ ] [Prontidão de backup](../backup-readiness/): snapshot, retenção e ao menos um teste de restauração já executados.
- [ ] Responsável operacional e canal de escalonamento definidos (veja [prontidão de workloads](../application-readiness/#responsabilidade-e-criticidade)).
- [ ] [Validação pós-instalação](../post-install-checklist/) executada para o núcleo e os módulos habilitados.

## Checkpoint

Todos os checklists linkados acima foram percorridos e os itens não aplicáveis têm justificativa registrada. Um workload não deveria receber tráfego real de produção antes desse checkpoint.

## Fontes e leitura adicional

- [Kubernetes — Production environment](https://kubernetes.io/docs/setup/production-environment/): considerações oficiais para operar um cluster em produção.
