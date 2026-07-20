---
title: Automatizar backups com Velero
sidebar:
  order: 3
---

> **Pré-requisitos:** Velero instalado e avaliado conforme [Velero como ferramenta a avaliar](../backup-and-recovery/#velero-como-ferramenta-a-avaliar); um `BackupStorageLocation` já configurado e testado com um backup manual.
> **Versões testadas:** Velero v1.18.

Esta página cobre a automação de backups já decididos, não a escolha inicial de Velero como ferramenta. A avaliação de versão, provider, plugins, suporte a CSI e política de retenção continua sendo tratada em [backup e recuperação](../backup-and-recovery/#velero-como-ferramenta-a-avaliar): confirme ali os pré-requisitos antes de tratar os agendamentos abaixo como definitivos.

## Agendamentos recorrentes

> **Executar em:** estação administrativa com o CLI `velero` configurado.

Um `Schedule` do Velero cria um novo `Backup` automaticamente a cada execução do cron informado. O exemplo abaixo agenda um backup diário às 2h, retendo cada backup por 30 dias (`720h`):

```bash
velero schedule create daily-backup \
  --schedule="0 2 * * *" \
  --include-namespaces '*' \
  --ttl 720h
```

O campo `--schedule` usa a sintaxe padrão de cron com cinco campos (minuto, hora, dia do mês, mês, dia da semana); não use o formato de seis campos de algumas ferramentas de nuvem, que insere um campo de segundos e produz um agendamento inválido no Velero. Um backup semanal aos domingos às 4h, por exemplo, se escreve `0 4 * * 0`, não `0 4 0 * * 0`.

O `--ttl` define quando o Velero pode expirar o backup e liberar o espaço correspondente no object storage; ele não é, por si só, uma política de retenção com granularidade por período (manter N diários, M semanais). Para isso, crie `Schedules` separados com TTLs diferentes, como no exemplo abaixo, em vez de tentar expressar toda a política em um único agendamento:

```bash
velero schedule create weekly-backup \
  --schedule="0 4 * * 0" \
  --include-namespaces '*' \
  --ttl 2160h
```

## Filtrar namespaces e recursos

`--include-namespaces` e `--exclude-namespaces` recebem uma lista de nomes exatos de namespace, separados por vírgula; não há suporte a padrões glob como `prod-*`. Quando o critério de seleção depende de um padrão de nome em vez de uma lista fixa, rotule os namespaces relevantes e filtre por label:

```bash
velero schedule create prod-backup \
  --schedule="0 2 * * *" \
  --selector environment=production
```

Esse `--selector` aplica-se aos recursos dentro dos namespaces incluídos, não à seleção dos namespaces em si; um backup completo de um subconjunto de namespaces com nomes irregulares ainda depende de listar os nomes explicitamente ou de organizar o cluster de forma que um label identifique o conjunto desejado de recursos.

`--include-resources` e `--exclude-resources` funcionam de forma equivalente para tipos de recurso, usando o nome plural em minúsculas (`deployments`, `services`, `configmaps`). Excluir `secrets` de um backup, por exemplo, evita duplicar segredos que já têm uma fonte externa e uma estratégia de backup própria (veja [credenciais, configuração e fonte de segredos](../backup-and-recovery/#credenciais-configuração-e-fonte-de-segredos)):

```bash
velero schedule create app-backup \
  --schedule="0 2 * * *" \
  --include-namespaces myapp \
  --exclude-resources secrets
```

## Hooks de pré e pós-backup

Hooks executam um comando dentro de um container antes ou depois do backup de um Pod, úteis para aplicações que precisam ser colocadas em um estado consistente antes da cópia (liberar um lock, sincronizar um buffer em memória). Eles se declaram como anotações no próprio Pod, não como parte do `BackupStorageLocation`, que descreve apenas o destino do backup:

```yaml
apiVersion: v1
kind: Pod
metadata:
  annotations:
    pre.hook.backup.velero.io/container: minha-aplicacao
    pre.hook.backup.velero.io/command: '["/bin/sh", "-c", "meu-comando-de-preparo"]'
    pre.hook.backup.velero.io/timeout: 30s
```

Para bancos de dados gerenciados por um operator, como o CloudNativePG usado neste notebook, prefira o mecanismo de backup nativo do operator (veja [backup do PostgreSQL](../backup-postgresql/)) em vez de um hook do Velero executando `pg_dump` manualmente: o operator já coordena WAL, consistência e retenção especificamente para o banco, enquanto um hook genérico de Velero replicaria essa lógica sem as mesmas garantias.

## Monitoramento

```bash
velero backup get
velero backup describe <nome-do-backup> --details
velero backup logs <nome-do-backup>
velero schedule get
```

`velero backup describe` mostra o resultado (`Completed`, `PartiallyFailed`, `Failed`), os itens processados e quaisquer avisos; um backup `Completed` com avisos pode ainda assim ter deixado recursos de fora, então revise a seção `Warnings` antes de considerar o backup íntegro. Integre esses comandos à mesma rotina de monitoramento e alertas descrita em [monitoramento e backups desatualizados](../backup-and-recovery/#monitoramento-e-backups-desatualizados).

Quando o Velero expõe métricas Prometheus (veja [instalar o Prometheus stack](../../../guides/tasks/observability/install-prometheus-stack/) e [configurar um `PodMonitor`](../../../guides/tasks/observability/configure-pod-monitor/)), confirme os nomes exatos das métricas expostas pela versão instalada antes de escrever regras de alerta; os nomes de métrica variam entre versões do Velero e não são fixados por este notebook.

## Teste de restauração

Restaurar em um namespace isolado, sem sobrescrever o original, é a forma mais direta de validar que um backup é utilizável:

```bash
kubectl create namespace velero-restore-test

velero restore create \
  --from-backup <nome-do-backup> \
  --namespace-mappings myapp:velero-restore-test \
  --wait

kubectl get all --namespace velero-restore-test

kubectl delete namespace velero-restore-test
```

`--namespace-mappings origem:destino` redireciona os recursos do namespace original para o namespace de teste durante a restauração, evitando qualquer conflito com o ambiente em produção. Depois de validar os recursos restaurados, descarte o namespace de teste; não o deixe como um segundo ambiente esquecido.

## Checklist

- [ ] Cada `Schedule` usa cron de cinco campos e foi conferido com `velero schedule describe <nome>` antes de considerar o agendamento ativo.
- [ ] `--ttl` de cada `Schedule` reflete a retenção decidida na [matriz de proteção](../backup-and-recovery/#modelo-de-matriz-de-proteção), não um valor arbitrário.
- [ ] Nenhum backup depende de filtro glob em `--include-namespaces`/`--exclude-namespaces`; namespaces são listados explicitamente ou selecionados por label.
- [ ] Hooks de pré/pós-backup (quando existirem) estão anotados no Pod, não em `BackupStorageLocation`.
- [ ] Bancos gerenciados por operator usam o backup nativo do operator, não um hook genérico do Velero.
- [ ] Um teste de restauração em namespace isolado foi executado dentro do prazo definido em [prontidão de backup](../../checklists/backup-readiness/).

## Troubleshooting

Se `velero backup describe` mostrar `PartiallyFailed` ou avisos na seção `Warnings`, o backup não deve ser tratado como equivalente a `Completed`: investigue os itens listados antes de assumir que a restauração recuperaria o estado completo. Se um `Schedule` não estiver gerando novos `Backups` no horário esperado, confirme que o controller do Velero está `Running` (`kubectl --namespace velero get pods`) e que a sintaxe do cron tem exatamente cinco campos.

## Próximo passo

[Backup e recuperação (política geral)](../backup-and-recovery/) para o inventário completo, a matriz de proteção e o roteiro de restore drill que este agendamento deve alimentar.

## Fontes e leitura adicional

- [Velero — How Velero Works](https://velero.io/docs/v1.18/how-velero-works/): explica o modelo de `Backup`, `Schedule`, `Restore` e `BackupStorageLocation`.
- [Velero — Schedule a Backup](https://velero.io/docs/v1.18/backup-reference/#schedule-a-backup): referência de `velero schedule create` e sintaxe de cron aceita.
- [Velero — Backup Hooks](https://velero.io/docs/v1.18/backup-hooks/): documenta anotações de hook em Pods e hooks declarados no `Backup`/`Schedule`.
- [Velero — Resource Filtering](https://velero.io/docs/v1.18/resource-filtering/): documenta `--include-namespaces`, `--exclude-namespaces`, `--include-resources`, `--exclude-resources` e seletores por label.
