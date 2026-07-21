---
title: Helm snippets
sidebar:
  order: 6
---

Fragmentos de `values.yaml` para copiar dentro de um chart já em edição. Para inspecionar releases já instaladas, ver values efetivos ou renderizar manifests sem instalar, veja o [cookbook de Helm](../../commands/helm/); esta página cobre o arquivo de valores em si, não os comandos.

## Recursos e imagem mínimos

```yaml
replicaCount: 2

image:
  repository: myapp
  tag: "1.4.0"
  pullPolicy: IfNotPresent

resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    memory: 256Mi
```

Campos que praticamente todo chart bem-formado aceita, mesmo quando o `values.yaml` padrão do chart tem dezenas de outras opções. Comece por esses antes de explorar o restante do schema com `helm show values <chart>`. Fixar `tag` explicitamente (em vez de aceitar o padrão do chart, que às vezes é `latest`) é o que torna a instalação reproduzível entre ambientes. Definir `limits.cpu` é opcional aqui de propósito: um limite de CPU rígido demais faz o processo ser sufocado (throttled) mesmo com CPU ociosa no nó; comece só com `requests.cpu` e adicione `limits.cpu` depois de observar o consumo real.

---

## Rota HTTPRoute opt-in (padrão deste notebook)

```yaml
gateway:
  name: internal
  namespace: gateway-system
  listener: websecure
  serviceName: minha-aplicacao
  servicePort: 80

httpRoute:
  # Opt-in: habilite somente depois de revisar Gateway, hostname e acesso de rede.
  enabled: false
```

Adaptado de [`templates/gitops/apps/management/rancher/values.yaml`](https://github.com/guesant/infrastructure-and-cluster-notebook/blob/main/templates/gitops/apps/management/rancher/values.yaml), o padrão usado pelos charts deste notebook que expõem uma interface via Gateway API: a rota vem desabilitada por padrão (`httpRoute.enabled: false`) para que instalar o chart nunca publique um serviço automaticamente. Habilitar a publicação é uma decisão separada e explícita, feita depois de confirmar qual Gateway, listener e hostname são apropriados para aquele ambiente; veja [Gateway API e Traefik](../../../guides/tasks/networking/configure-traefik-gateway-api/) para o procedimento completo de publicação.

## Referências

- [Helm: values files](https://helm.sh/docs/chart_template_guide/values_files/): como o Helm combina o `values.yaml` padrão do chart com os arquivos e overrides fornecidos.
- [Templates copiáveis](../../../guides/blueprints/k3s-single-node-gitops/templates/): descreve os templates reais deste notebook, incluindo o padrão de rota opt-in.
