---
title: Argo CD snippets
sidebar:
  order: 5
---

Fragmentos de `Application` do Argo CD no padrão App-of-Apps usado por este notebook. Para o procedimento completo (estruturar o repositório, aplicar a Application raiz, validar a sincronização), veja [estruturar o repositório GitOps](../../../guides/tasks/gitops/structure-gitops-repository/) e [criar a Application raiz](../../../guides/tasks/gitops/create-root-application/); esta página só reúne os fragmentos.

## Application raiz (App-of-Apps)

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: root
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/example/cluster-config.git
    targetRevision: main
    path: gitops/applications
    directory:
      recurse: false
  destination:
    server: https://kubernetes.default.svc
    namespace: argocd
  syncPolicy:
    automated:
      prune: false
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

Este é o manifesto real usado por [`templates/gitops/root/application.yaml`](https://github.com/guesant/infrastructure-and-cluster-notebook/blob/main/templates/gitops/root/application.yaml). Ele observa `gitops/applications/` (`directory.recurse: false`, então só o primeiro nível do diretório, não subpastas) e cada arquivo YAML encontrado ali vira uma `Application` independente que o Argo CD reconcilia sozinha. `prune: false` evita que remover um arquivo do Git apague automaticamente o recurso correspondente no cluster; habilite só depois de revisar esse comportamento para o ambiente.

---

## Application de um componente (chart Helm no mesmo repositório)

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: minha-aplicacao
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/example/cluster-config.git
    targetRevision: main
    path: gitops/apps/categoria/minha-aplicacao
    helm:
      valueFiles:
        - values.yaml
  destination:
    server: https://kubernetes.default.svc
    namespace: minha-aplicacao
  syncPolicy:
    automated:
      prune: false
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

Adaptado de [`templates/gitops/applications/rancher.yaml`](https://github.com/guesant/infrastructure-and-cluster-notebook/blob/main/templates/gitops/applications/rancher.yaml). Diferente da Application raiz, `source.path` aponta para um diretório com um `Chart.yaml` e `values.yaml` (um chart Helm local ao repositório, não manifests puros); `helm.valueFiles` lista os arquivos de valores a aplicar, relativos a esse mesmo diretório. `syncOptions: [CreateNamespace=true]` cria o namespace de destino automaticamente na primeira sincronização, o que evita um passo manual de `kubectl create namespace` antes de aplicar a Application.

## Referências

- [Argo CD: Especificação de `Application`](https://argo-cd.readthedocs.io/en/stable/user-guide/application-specification/): referência completa dos campos de origem, destino e política de sincronização.
- [Templates copiáveis](../../../guides/blueprints/k3s-single-node-gitops/templates/): descreve o que cada Application do template oferece e como copiá-las para outro repositório.
