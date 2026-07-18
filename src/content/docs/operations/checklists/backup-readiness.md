---
title: Prontidão de backup
sidebar:
  order: 5
---

> **Para quem é:** quem precisa confirmar se a estratégia de backup do cluster está completa antes de depender dela em um incidente real.

Checklist especializado referenciado pelo [checklist central](../cluster-operational-checklist/). Detalha os itens descritos na política completa de [backup e recuperação](../../backups/backup-and-recovery/).

- [ ] Recursos declarativos versionados em Git (fora do cluster)
  - Explicação e configuração: [estruturar o repositório GitOps](../../../guides/tasks/gitops/structure-gitops-repository/)
  - Verificação: `git -C gitops/ log -1 --format=%H`
  - Frequência: contínua (cada commit já é a proteção)

- [ ] Dados persistentes com backup próprio, fora do domínio de falha do cluster
  - Explicação e configuração: [backup e recuperação — limites do Longhorn](../../backups/backup-and-recovery/#limites-do-longhorn)
  - Verificação: revisão manual do backup target do Longhorn
  - Frequência: mensal

- [ ] Datastore do cluster (etcd) com snapshot recente e copiado externamente
  - Explicação e configuração: [backup do etcd](../../backups/backup-k3s-etcd/)
  - Verificação: `k3s etcd-snapshot list` e confirmação manual da cópia externa
  - Frequência: antes de cada mudança relevante; snapshot agendado contínuo

- [ ] Secrets e fonte de credenciais com estratégia de recuperação definida
  - Explicação e configuração: [backup e recuperação — credenciais e fonte de segredos](../../backups/backup-and-recovery/#credenciais-configuração-e-fonte-de-segredos)
  - Verificação: revisão manual do procedimento de recuperação de emergência
  - Frequência: trimestral

- [ ] Cópias fora do cluster e fora do domínio de falha original
  - Explicação e configuração: [backup e recuperação — destino e controles de segurança](../../backups/backup-and-recovery/#destino-e-controles-de-segurança)
  - Verificação: revisão manual da localização física/lógica do destino
  - Frequência: trimestral

- [ ] Retenção definida e compatível com o RPO
  - Explicação e configuração: [backup e recuperação — frequência e retenção](../../backups/backup-and-recovery/#frequência-e-retenção)
  - Verificação: revisão manual da política de retenção configurada
  - Frequência: trimestral

- [ ] Criptografia dos backups em repouso e em trânsito
  - Explicação e configuração: [backup e recuperação — destino e controles de segurança](../../backups/backup-and-recovery/#destino-e-controles-de-segurança)
  - Verificação: revisão manual da configuração de criptografia do destino
  - Frequência: trimestral

- [ ] Testes de restauração executados e cronometrados
  - Explicação e configuração: [roteiro de restore drill](../../backups/backup-and-recovery/#roteiro-de-restore-drill)
  - Verificação: registro do último drill executado
  - Frequência: trimestral

- [ ] RPO definido e validado pelo último teste de restauração
  - Explicação e configuração: [backup e recuperação — RPO e RTO](../../backups/backup-and-recovery/#rpo-e-rto)
  - Verificação: comparação entre RPO definido e perda observada no último drill
  - Frequência: trimestral

- [ ] RTO definido e validado pelo último teste de restauração
  - Explicação e configuração: [backup e recuperação — RPO e RTO](../../backups/backup-and-recovery/#rpo-e-rto)
  - Verificação: comparação entre RTO definido e duração observada no último drill
  - Frequência: trimestral

- [ ] Plano de disaster recovery documentado e acessível durante uma indisponibilidade
  - Explicação e configuração: [reconstruir um cluster single-node](../../disaster-recovery/rebuild-single-node-cluster/)
  - Verificação: confirmar que o runbook está acessível fora do cluster (não só como página do próprio site publicado a partir do cluster)
  - Frequência: trimestral

## Fontes e leitura adicional

- [K3s — Backup and Restore](https://docs.k3s.io/datastore/backup-restore): referência oficial de backup e restauração do datastore.
