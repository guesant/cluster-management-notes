---
title: Traefik e Gateway API snippets
sidebar:
  order: 7
---

Fragmentos de `GatewayClass`, `Gateway` e `HTTPRoute` consistentes com o Traefik configurado em [Gateway API e Traefik](../../../guides/tasks/networking/configure-traefik-gateway-api/): mesmos nomes de porta (`web`/`websecure`), mesmo provider (`kubernetesGateway`) e a mesma convenção de namespace (`gateway-system`) usada pelos charts deste notebook que publicam uma rota (veja o bloco `gateway:` em [`templates/gitops/apps/management/rancher/values.yaml`](https://github.com/guesant/infrastructure-and-cluster-notebook/blob/main/templates/gitops/apps/management/rancher/values.yaml)). Aquele guia instala os CRDs e habilita o provider, mas não cria `GatewayClass` nem `Gateway`; esta página cobre exatamente essa lacuna. Para uma `HTTPRoute` genérica e mais simples, veja também [expor via HTTPRoute](../kubernetes/#expor-via-httproute-gateway-api) no snippet de Kubernetes.

## GatewayClass

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: traefik
spec:
  controllerName: traefik.io/gateway-controller
```

Recurso de escopo de cluster, criado uma única vez. `controllerName` identifica qual controller implementa essa classe; o valor `traefik.io/gateway-controller` é o documentado pelo próprio provider Gateway API do Traefik (veja a [referência oficial](https://doc.traefik.io/traefik/reference/install-configuration/providers/kubernetes/kubernetes-gateway/) antes de fixar essa string em automação, caso o projeto renomeie o controller em uma versão futura).

---

## Gateway com listeners HTTP e HTTPS

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: internal
  namespace: gateway-system
spec:
  gatewayClassName: traefik
  listeners:
    - name: web
      port: 80
      protocol: HTTP
      allowedRoutes:
        namespaces:
          from: All
    - name: websecure
      port: 443
      protocol: HTTPS
      tls:
        mode: Terminate
        certificateRefs:
          - name: internal-gateway-tls
      allowedRoutes:
        namespaces:
          from: All
```

`internal`/`gateway-system` é o nome e o namespace que os charts deste notebook já esperam ao referenciar um Gateway (veja `gateway.name`/`gateway.namespace` no `values.yaml` do Rancher, linkado acima). Os nomes de listener (`web`, `websecure`) casam com os nomes de porta configurados no `HelmChartConfig` do Traefik. `allowedRoutes.namespaces.from: All` permite que `HTTPRoute`s de qualquer namespace se associem a este Gateway; restrinja para `Same` ou uma seleção por label quando isolar por namespace for um requisito. `certificateRefs` aponta para um `Secret` do tipo TLS que o cert-manager mantém atualizado a partir de um `Certificate`; veja [criar um ClusterIssuer ACME](../../../guides/tasks/certificates/create-acme-clusterissuer/) para emitir esse certificado automaticamente em vez de fornecê-lo manualmente.

---

## HTTPRoute associada a um listener específico

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: minha-aplicacao
  namespace: minha-aplicacao
spec:
  parentRefs:
    - name: internal
      namespace: gateway-system
      sectionName: websecure
  hostnames:
    - minha-aplicacao.internal.example.com
  rules:
    - backendRefs:
        - name: minha-aplicacao
          port: 80
```

Diferente do exemplo genérico em [expor via HTTPRoute](../kubernetes/#expor-via-httproute-gateway-api), este usa `sectionName` para associar a rota especificamente ao listener `websecure` do Gateway `internal` (em vez de todos os listeners do Gateway), o mesmo padrão usado por [`templates/gitops/apps/management/rancher/templates/rancher-httproute.yaml`](https://github.com/guesant/infrastructure-and-cluster-notebook/blob/main/templates/gitops/apps/management/rancher/templates/rancher-httproute.yaml). Quando o `Gateway` referenciado está em outro namespace (como aqui, `gateway-system` diferente do namespace da aplicação), `parentRefs[].namespace` é obrigatório; sem ele, o Traefik assume o mesmo namespace da `HTTPRoute`.

## Referências

- [Gateway API: referência de `Gateway`](https://gateway-api.sigs.k8s.io/api-types/gateway/): campos de `listeners`, `allowedRoutes` e `tls`.
- [Gateway API: referência de `HTTPRoute`](https://gateway-api.sigs.k8s.io/api-types/httproute/): `parentRefs`, `sectionName` e regras de correspondência.
- [Provider Kubernetes Gateway do Traefik](https://doc.traefik.io/traefik/reference/install-configuration/providers/kubernetes/kubernetes-gateway/): `controllerName` e opções do provider.
