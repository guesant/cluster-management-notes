---
title: Helm
sidebar:
  order: 6.5
---

## Listar releases instaladas

```bash
helm list --all-namespaces
# Nome, namespace, revisão, status, chart e versão do app de cada release

helm list --namespace monitoring
# Só as releases de um namespace específico
```

**Quando usar:** ver o que está instalado via Helm no cluster, e em qual revisão e status cada release está, antes de investigar ou alterar algo.

**Considerações:**

- `helm list` mostra só releases gerenciadas pelo Helm; um recurso aplicado diretamente com `kubectl apply`, mesmo que originado de um chart, não aparece aqui.
- O `STATUS` reportado (`deployed`, `failed`, `pending-upgrade`, entre outros) reflete o resultado da última operação Helm sobre a release, não necessariamente a saúde atual dos Pods; confirme com [verificar o status do cluster](../kubernetes/#verificar-o-status-do-cluster) para o estado real dos recursos.

---

## Ver os values efetivos de uma release

```bash
helm get values kube-prometheus-stack --namespace monitoring
# Só os values customizados, passados explicitamente na instalação

helm get values kube-prometheus-stack --namespace monitoring --all
# Values customizados combinados com os padrões do chart
```

**Quando usar:** confirmar qual configuração está de fato ativa em uma release, sem depender de lembrar o que foi passado no `--values` original.

**Considerações:**

- Sem `--all`, o comando mostra só os valores que sobrescrevem o padrão do chart; isso costuma ser mais legível, mas esconde o valor efetivo dos campos não customizados.
- `--all` mostra o resultado do merge completo entre o `values.yaml` padrão do chart e cada `--values`/`--set` aplicado, na ordem em que foram informados. É essa combinação, não o `values.yaml` isolado, que corresponde ao que o Helm de fato renderizou.

---

## Consultar o histórico e reverter uma release

```bash
helm history kube-prometheus-stack --namespace monitoring
# Revisão, data, status e descrição de cada operação sobre a release

helm rollback kube-prometheus-stack 2 --namespace monitoring
# Reverte para a revisão 2 especificamente

helm rollback kube-prometheus-stack --namespace monitoring
# Sem número, reverte para a revisão anterior à atual
```

**Quando usar:** identificar quando e o que mudou em uma release ao longo do tempo, e reverter uma atualização que causou um problema.

**Considerações:**

- Cada `helm upgrade` bem-sucedido ou falho cria uma nova revisão; `helm history` é o registro dessas revisões, não um diff automático entre elas.
- `helm rollback` reaplica os manifests da revisão de destino; não desfaz efeitos colaterais fora do cluster (uma migração de banco de dados executada por um hook, por exemplo).
- Em um cluster com GitOps (Argo CD ou Flux gerenciando a release), um `helm rollback` manual entra em conflito com a fonte de verdade declarada no Git: o próximo ciclo de sincronização reaplica o estado do Git e desfaz o rollback. Nesse modelo, reverter significa mudar o Git, não rodar `helm rollback` diretamente no cluster.

---

## Renderizar os manifests sem instalar (`helm template`)

```bash
helm template kube-prometheus-stack kube-prometheus-stack \
  --repo https://prometheus-community.github.io/helm-charts \
  --namespace monitoring \
  --values values.yaml
# Imprime o YAML final que o Helm aplicaria, sem tocar o cluster
```

**Quando usar:** depurar um chart antes de instalar ou atualizar, revisar exatamente quais recursos e campos um conjunto de values produz, ou inspecionar um chart de terceiros antes de confiar nele.

**Considerações:**

- `helm template` não se conecta ao cluster nem consulta o estado atual; alguns charts usam funções como `lookup` que dependem de uma API Kubernetes acessível e produzem um resultado incompleto ou diferente do que `helm install`/`upgrade` geraria.
- Combine com `--values` e `--set` do mesmo jeito que em `helm upgrade --install`, para conferir o efeito exato da configuração antes de aplicá-la de verdade; ver [instalar o kube-prometheus-stack](../../../guides/tasks/observability/install-prometheus-stack/) para um exemplo completo de instalação com `helm upgrade --install`.
- Redirecionar a saída para `kubectl diff -f -` (quando o plugin de diff estiver disponível) mostra a diferença entre o que o chart renderiza agora e o que está de fato aplicado no cluster, sem precisar rodar o upgrade primeiro.

---

## Relacionado

- [Instalar o kube-prometheus-stack](../../../guides/tasks/observability/install-prometheus-stack/), [instalar o OpenBao](../../../guides/tasks/secrets/install-openbao/) e [instalar o Sealed Secrets](../../../guides/tasks/secrets/install-sealed-secrets/), exemplos de instalação via `helm upgrade --install` seguidos neste notebook.
- [Verificar o status do cluster](../kubernetes/#verificar-o-status-do-cluster) e [descrever um Pod](../kubernetes/#descrever-um-pod), para investigar o estado real dos recursos depois de confirmar o que o Helm reporta.
