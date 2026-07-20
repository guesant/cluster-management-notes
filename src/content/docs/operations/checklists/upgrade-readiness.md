---
title: Prontidão para atualização
sidebar:
  order: 7
---

> **Para quem é:** quem vai planejar uma atualização de K3s, chart ou componente de plataforma.

Este checklist consolida os itens relevantes antes de uma janela de atualização. Ele não substitui os procedimentos específicos: cada linha aponta para a página correspondente.

- [ ] Notas de versão e compatibilidade revisadas para o componente que será atualizado.
- [ ] [Backup do etcd](../../backups/backup-k3s-etcd/) recente e copiado para fora do host antes de iniciar.
- [ ] Critérios de sucesso e de interrupção definidos antes de começar (veja [runbook de manutenção](../../maintenance/maintenance-runbook/)).
- [ ] Janela de indisponibilidade comunicada: em nó único, qualquer atualização de K3s interrompe o cluster inteiro.
- [ ] [Prontidão de observabilidade](../observability-readiness/) confirmada, para detectar problemas durante e depois da atualização.
- [ ] Procedimento específico identificado:
  - K3s: [atualizar o K3s (nó único)](../../upgrades/upgrade-k3s-single-node/)
  - Componentes de plataforma (cert-manager, Argo CD, Longhorn): notas de versão do respectivo task guide de instalação.
- [ ] Rollback conhecido e testado, não apenas presumido (para K3s, veja [restaurar o etcd](../../disaster-recovery/restore-k3s-etcd/)).

## Checkpoint

O item de backup e o critério de rollback estão confirmados antes de iniciar qualquer atualização: sem eles, uma atualização com problema se torna um incidente de disaster recovery em vez de um rollback simples.

## Fontes e leitura adicional

- [K3s — Manual Upgrades](https://docs.k3s.io/upgrades/manual): referência oficial do processo de atualização.
