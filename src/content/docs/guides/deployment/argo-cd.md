---
title: Argo CD
sidebar:
  order: 2
---

Os comandos desta página devem ser executados em um servidor ou em uma estação administrativa que tenha `kubectl`, Helm, acesso à API e um kubeconfig válido.

## O que é e para que serve

O Argo CD é um controlador de entrega contínua para Kubernetes baseado em GitOps. Em vez de usar a estação administrativa para reaplicar os manifests a cada mudança, o Argo CD observa o estado desejado registrado em um repositório Git, compara esse conteúdo com os recursos existentes no cluster e informa quando há diferenças. Dependendo da política configurada, ele pode sincronizar essas diferenças automaticamente e corrigir alterações feitas diretamente no cluster.

O principal recurso do Argo CD é a `Application`. Cada `Application` informa qual repositório, revisão e caminho devem ser observados, em qual cluster e namespace o conteúdo será aplicado e qual política de sincronização será usada. Assim, o Git passa a registrar o estado desejado e o histórico das mudanças, enquanto o Argo CD faz a reconciliação com o cluster.

O Argo CD não substitui a revisão de código, o controle de acesso ao repositório nem um gerenciador de segredos. Não versione credenciais em manifests: forneça ao Argo CD apenas a credencial necessária para ler o repositório privado e use o mecanismo de segredos adotado pelo ambiente para os dados das aplicações.

Instale uma versão fixa do chart. O servidor permanece com TLS habilitado e sem Ingress; o acesso inicial será por port-forward.

> **Executar em:** qualquer máquina com `KUBECONFIG`, Helm e acesso administrativo à API.

```bash
read -r -p "Versão do chart Argo CD [10.1.3]: " ARGO_CD_CHART_VERSION
read -r -p "CPU solicitada pelo servidor [100m]: " ARGO_CD_CPU_REQUEST
read -r -p "Memória solicitada pelo servidor [128Mi]: " ARGO_CD_MEMORY_REQUEST
read -r -p "Limite de CPU do servidor [500m]: " ARGO_CD_CPU_LIMIT
read -r -p "Limite de memória do servidor [512Mi]: " ARGO_CD_MEMORY_LIMIT

ARGO_CD_CHART_VERSION="${ARGO_CD_CHART_VERSION:-10.1.3}"
ARGO_CD_CPU_REQUEST="${ARGO_CD_CPU_REQUEST:-100m}"
ARGO_CD_MEMORY_REQUEST="${ARGO_CD_MEMORY_REQUEST:-128Mi}"
ARGO_CD_CPU_LIMIT="${ARGO_CD_CPU_LIMIT:-500m}"
ARGO_CD_MEMORY_LIMIT="${ARGO_CD_MEMORY_LIMIT:-512Mi}"

helm upgrade --install argocd argo-cd \
  --repo https://argoproj.github.io/argo-helm \
  --version "${ARGO_CD_CHART_VERSION}" \
  --namespace argocd \
  --create-namespace \
  --set server.ingress.enabled=false \
  --set-string server.resources.requests.cpu="${ARGO_CD_CPU_REQUEST}" \
  --set-string server.resources.requests.memory="${ARGO_CD_MEMORY_REQUEST}" \
  --set-string server.resources.limits.cpu="${ARGO_CD_CPU_LIMIT}" \
  --set-string server.resources.limits.memory="${ARGO_CD_MEMORY_LIMIT}" \
  --wait \
  --timeout 10m
```

Valide a instalação:

> **Executar em:** qualquer máquina com `KUBECONFIG` e acesso à API.

```bash
kubectl --namespace argocd rollout status deployment/argocd-server --timeout=180s
kubectl --namespace argocd get pods
helm --namespace argocd status argocd
```

Encaminhe localmente o servidor HTTPS:

> **Executar em:** estação administrativa com `KUBECONFIG` e acesso à API.

```bash
read -r -p "Porta local para o Argo CD [8080]: " LOCAL_PORT
LOCAL_PORT="${LOCAL_PORT:-8080}"

kubectl --namespace argocd \
  port-forward service/argocd-server "${LOCAL_PORT}:443"
```

Acesse `https://127.0.0.1:PORTA_LOCAL`, substituindo `PORTA_LOCAL` pelo valor informado. O certificado inicial é autoassinado.

Obtenha a senha inicial sem deixá-la sem newline no terminal:

> **Executar em:** qualquer máquina com `KUBECONFIG` e acesso à API.

```bash
kubectl --namespace argocd \
  get secret argocd-initial-admin-secret \
  --output jsonpath='{.data.password}' \
  | base64 --decode
printf '\n'
```

Troque a senha inicial imediatamente. Com a CLI instalada:

> **Executar em:** estação administrativa com a CLI e o port-forward ativos.

```bash
read -r -p "Porta local usada pelo port-forward do Argo CD [8080]: " LOCAL_PORT
LOCAL_PORT="${LOCAL_PORT:-8080}"

argocd login "127.0.0.1:${LOCAL_PORT}" --username admin --insecure
argocd account update-password
```

Depois de trocar a senha, remova o secret inicial caso ele ainda exista:

> **Executar em:** qualquer máquina com `KUBECONFIG` e acesso administrativo à API.

```bash
kubectl --namespace argocd delete secret argocd-initial-admin-secret
```

Depois da instalação e da troca da senha inicial, continue em [Bootstrap GitOps com Argo CD](../gitops-bootstrap/).

## Fontes e leitura adicional

- [Getting Started — Argo CD](https://argo-cd.readthedocs.io/en/stable/getting_started/): fluxo oficial de instalação, acesso inicial e criação de uma aplicação.
- [Helm chart do Argo CD](https://github.com/argoproj/argo-helm/tree/main/charts/argo-cd): valores, templates e notas de versão do chart usado nesta página.
- [Gestão de usuários — Argo CD](https://argo-cd.readthedocs.io/en/stable/operator-manual/user-management/): orienta sobre a conta `admin`, usuários locais e integração com provedores de identidade.
- [Práticas de segurança — Argo CD](https://argo-cd.readthedocs.io/en/stable/operator-manual/security/): reúne o modelo de segurança, divulgações e recomendações operacionais do projeto.
