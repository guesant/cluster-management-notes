---
title: Manutenção de nós
sidebar:
  order: 1
---

Esta página funciona como roteiro para as rotinas de manutenção aplicadas a um nó individual, diferente de [manutenção e atualização do K3s](../k3s-cluster-maintenance/), que cobre o cluster como um todo.

| Rotina | Página | Frequência sugerida |
| --- | --- | --- |
| Drenar e reintegrar para manutenção temporária | [Drenar e reintegrar um nó](../drain-and-uncordon-node/) | Sob demanda, antes de qualquer intervenção no host. |
| Capacidade de disco | [Revisão de capacidade de disco](../disk-capacity-review/) | Mensal, ou por alerta. |
| Certificados | [Revisão de certificados](../certificate-review/) | Semanal, ou por alerta. |
| Atualizações de segurança do SO | [Atualizações automáticas de segurança](../../../guides/tasks/host/configure-automatic-security-updates/) | Contínua, com revisão de reinícios pendentes conforme o [runbook de manutenção](../maintenance-runbook/). |
| Journal e logs | [Journal persistente](../../../guides/tasks/host/configure-persistent-journal/) | Verificar retenção mensalmente. |

## Checkpoint

Cada rotina aplicável ao ambiente está registrada com uma frequência definida no [runbook de manutenção e mudanças](../maintenance-runbook/), e nenhuma delas foi pulada sem justificativa registrada.

## Fontes e leitura adicional

- [Kubernetes — Node](https://kubernetes.io/docs/concepts/architecture/nodes/): referência do ciclo de vida e condições de um nó.
