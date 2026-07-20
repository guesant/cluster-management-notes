---
title: Manutenção e atualização do K3s
sidebar:
  order: 6
---

Esta página funciona como roteiro para as manutenções recorrentes de um cluster K3s. Ela não repete os comandos: cada linha aponta para a página específica que os documenta.

| Manutenção | Página | Quando usar |
| --- | --- | --- |
| Backup do datastore | [Backup do etcd](../../backups/backup-k3s-etcd/) | Antes de qualquer atualização ou mudança relevante de configuração. |
| Atualização de versão | [Atualizar o K3s (nó único)](../../upgrades/upgrade-k3s-single-node/) | Ao adotar uma nova versão do K3s. |
| Manutenção temporária de um nó | [Drenar e reintegrar um nó](../drain-and-uncordon-node/) | Reinício do host, atualização de pacotes, troca de hardware; o nó continua no cluster. |
| Remoção permanente de um nó | [Remover um nó do K3s](../../../guides/tasks/kubernetes/remove-k3s-node/) e [desinstalar o K3s](../../../guides/tasks/kubernetes/uninstall-k3s/) | O nó sai definitivamente do cluster. |
| Capacidade de disco | [Revisão de capacidade de disco](../disk-capacity-review/) | Rotina periódica ou alerta de espaço em disco. |
| Certificados | [Revisão de certificados](../certificate-review/) | Rotina periódica ou alerta de vencimento próximo. |

Nenhuma dessas manutenções é isolada da anterior: um snapshot desatualizado antes de uma atualização, por exemplo, é a causa mais comum de uma atualização mal sucedida virar perda de dados. Siga a ordem acima quando as manutenções coincidirem.

## Checkpoint

Cada manutenção realizada está registrada no [runbook de manutenção e mudanças](../maintenance-runbook/), com responsável, resultado e evidência.

## Fontes e leitura adicional

- [K3s — Backup and Restore](https://docs.k3s.io/datastore/backup-restore): referência oficial de backup e restauração do datastore.
- [K3s — Manual Upgrades](https://docs.k3s.io/upgrades/manual): referência oficial de atualização de versão.
