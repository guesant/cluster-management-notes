---
title: Guia de operação contínua
description: Índice dos checklists especializados usados para manter um cluster K3s seguro, observável, recuperável e atualizado ao longo do tempo.
---

Este guia funciona como **índice**, não como uma página única contendo todas as explicações — cada categoria abaixo aponta para o checklist especializado correspondente, que detalha explicação, configuração, comando de verificação e frequência de cada item. Ele complementa a [validação pós-instalação](../post-install-checklist/): a validação confirma que o cluster terminou o bootstrap em condições conhecidas; este índice ajuda a mantê-lo assim ao longo do tempo.

## Como usar este guia

- Copie os itens aplicáveis de cada checklist especializado para uma issue, ticket ou runbook operacional.
- Registre responsável, data, resultado e uma evidência para cada execução.
- Marque um item como não aplicável somente com a justificativa registrada.
- Ajuste a frequência sugerida à criticidade do ambiente e ao impacto de indisponibilidade.
- Transforme falhas encontradas em ações com responsável e prazo, em vez de apenas desmarcar o item.

## Categorias

| Categoria | Checklist | Cobre |
| --- | --- | --- |
| Segurança do host | [Segurança do host](../host-security/) | Atualizações, SSH, firewall, força bruta, serviços, permissões, logs |
| Segurança do cluster | [Segurança do cluster](../cluster-security/) | RBAC, kubeconfig, namespaces, NetworkPolicies, Pod Security, secrets, imagens, certificados |
| Disponibilidade das aplicações | [Prontidão de workloads](../application-readiness/) | Probes, recursos, PDB, rollout, réplicas, dependências, rollback |
| Observabilidade | [Prontidão de observabilidade](../observability-readiness/) | Métricas, logs, dashboards, alertas, retenção, monitoramento externo |
| Backups e recuperação | [Prontidão de backup](../backup-readiness/) | Datastore, volumes, secrets, retenção, RPO/RTO, testes de restauração |
| Atualizações | [Prontidão para atualização](../upgrade-readiness/) | Compatibilidade, backup prévio, janela, rollback |
| Dependências | [Ciclo de vida de imagens](../../../learn/containers/image-lifecycle/) | Versões, digests, matriz de compatibilidade de componentes |
| Manutenção recorrente | [Manutenção de nós](../../maintenance/node-maintenance/) e [runbook de manutenção](../../maintenance/maintenance-runbook/) | Rotinas periódicas, registro de execuções |
| Documentação e procedimentos | Esta página e os checklists linkados | Runbooks acessíveis durante uma indisponibilidade |

## Checklists por cenário

Para uma visão consolidada por situação, em vez de por categoria:

- [Prontidão para produção](../production-readiness/) — antes de colocar um cluster ou workload em produção pela primeira vez.
- [Prontidão para atualização](../upgrade-readiness/) — antes de uma janela de atualização.
- [Prontidão para disaster recovery](../disaster-recovery-readiness/) — para confirmar que uma perda total do host é de fato recuperável.

## Rotina recorrente

Registre as execuções com o [runbook de manutenção e mudanças](../../maintenance/maintenance-runbook/). As categorias acima definem a cobertura; o runbook guarda responsável, resultado, evidência, exceções e ações pendentes sem duplicar os checklists.

| Cadência | O que revisar |
| --- | --- |
| Contínua ou diária | Saúde de nós, control plane, workloads críticos e endpoints externos; conclusão do último backup esperado. |
| Semanal | Alertas disparados, [certificados](../../maintenance/certificate-review/), tags flutuantes ou imagens sem inventário. |
| Mensal ou por janela | Novas versões disponíveis, [capacidade de disco](../../maintenance/disk-capacity-review/), capacidade de observabilidade, responsáveis e runbooks. |
| Trimestral ou por criticidade | [Restore drill completo](../../backups/backup-and-recovery/#roteiro-de-restore-drill), teste de alertas, revisão de acessos e credenciais. |

## Antes e depois de uma manutenção

Use o [runbook de manutenção e mudanças](../../maintenance/maintenance-runbook/) para registrar baseline, responsáveis, janela, critérios objetivos, rollback e observação posterior. Antes de iniciar, confirme [prontidão para atualização](../upgrade-readiness/); depois, revalide [prontidão de observabilidade](../observability-readiness/) e os fluxos críticos definidos em [prontidão de workloads](../application-readiness/).

## Procedimentos relacionados

- [Validação pós-instalação](../post-install-checklist/)
- [Manutenção e atualização do K3s](../../maintenance/k3s-cluster-maintenance/)
- [Backup e recuperação](../../backups/backup-and-recovery/)
- [Runbook de manutenção e mudanças](../../maintenance/maintenance-runbook/)
- [Argo CD](../../../guides/tasks/gitops/install-argocd/) e [bootstrap GitOps](../../../guides/tasks/gitops/bootstrap-gitops/)
- [Identidade e RBAC](../../../guides/tasks/kubernetes/configure-rbac/)
- [NetworkPolicy](../../../guides/tasks/networking/configure-network-policies/)
- [Ciclo de vida de imagens](../../../learn/containers/image-lifecycle/)
- [Observabilidade e alertas](../../observability/observability-and-alerting/)

## Fontes e leitura adicional

- [Kubernetes — Production environment](https://kubernetes.io/docs/setup/production-environment/): considerações oficiais para operar um cluster em produção.
- [Disrupções e PodDisruptionBudgets — Kubernetes](https://kubernetes.io/docs/concepts/workloads/pods/disruptions/): distingue disrupções voluntárias e involuntárias e define os limites de um PDB.
