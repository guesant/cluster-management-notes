---
title: Prontidão para disaster recovery
sidebar:
  order: 8
---

> **Para quem é:** quem precisa confirmar se o cluster está de fato recuperável de uma perda total do host, não apenas "tem backup".

Este checklist consolida os itens relevantes para o cenário de perda completa do host, o pior caso em uma topologia single-node. Ele não substitui a política completa em [backup e recuperação](../../backups/backup-and-recovery/).

- [ ] [Prontidão de backup](../backup-readiness/) completa: sem isso, não há o que recuperar.
- [ ] Snapshot do etcd e token do servidor acessíveis a partir de fora do host original.
- [ ] Repositório GitOps acessível a partir de fora do host original (já é o caso por natureza, mas confirme credenciais de acesso).
- [ ] Dados de volumes persistentes (Longhorn ou outro) com backup fora do host original.
- [ ] Credenciais e fonte de segredos recuperáveis sem depender do cluster perdido.
- [ ] Procedimento de reconstrução conhecido: [reconstruir um cluster single-node](../../disaster-recovery/rebuild-single-node-cluster/).
- [ ] Um restore drill completo (não apenas do etcd isoladamente) já foi executado e cronometrado; veja o [roteiro de restore drill](../../backups/backup-and-recovery/#roteiro-de-restore-drill).
- [ ] RTO medido no último drill é compatível com a tolerância real de indisponibilidade do ambiente.
- [ ] Acesso de emergência (credenciais, DNS, provedor de infraestrutura) documentado fora do próprio cluster.

## Checkpoint

O item do restore drill completo é o que realmente comprova prontidão: os demais itens sem um drill executado são apenas uma hipótese não testada. Não considere o ambiente pronto para disaster recovery sem pelo menos uma execução registrada.

## Fontes e leitura adicional

- [K3s — Backup and Restore](https://docs.k3s.io/datastore/backup-restore): referência oficial de backup e restauração usada pelo procedimento de reconstrução.
