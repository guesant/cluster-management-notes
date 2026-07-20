---
title: Kubernetes snippets
sidebar:
  order: 3
---

## Deployment básico

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
        - name: app
          image: myapp:1.0
          ports:
            - containerPort: 8000
```

Três réplicas de `myapp`, selecionadas pelo label `app: myapp`. Antes de usar em produção, veja [prontidão de workloads](../../../operations/checklists/application-readiness/) para requests/limits, probes e demais campos que este exemplo mínimo omite.

---

## Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp-svc
spec:
  selector:
    app: myapp
  ports:
    - port: 80
      targetPort: 8000
  type: ClusterIP
```

Expõe o Deployment dentro do cluster. `type: ClusterIP` (o padrão, mostrado aqui explicitamente) só é alcançável de dentro do cluster; troque para `NodePort` para expor uma porta fixa em cada nó, ou `LoadBalancer` quando o cluster tiver um provisionador de load balancer externo integrado, o que normalmente não é o caso de um K3s bare metal sem um componente adicional como o MetalLB.

---

## ConfigMap montado como volume

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  app.conf: |
    server {
      listen 8000;
    }
  debug: "true"
```

```yaml
# Trecho do Deployment que consome o ConfigMap acima (excerto, não um manifesto completo)
spec:
  template:
    spec:
      volumes:
        - name: config
          configMap:
            name: app-config
      containers:
        - volumeMounts:
            - name: config
              mountPath: /etc/app
```

O ConfigMap guarda dados de configuração como um objeto separado do Deployment; o segundo bloco mostra apenas a parte do `spec` do Deployment responsável por montá-lo como volume, não um manifesto completo e aplicável isoladamente.

---

## Secret referenciado por variável de ambiente

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-secret
type: Opaque
data:
  username: YWRtaW4=      # "admin", codificado em base64
  password: cGFzc3dvcmQ=  # valor de exemplo, nunca use em produção
```

```yaml
# Trecho do container que consome o Secret acima (excerto, não um manifesto completo)
containers:
  - name: app
    env:
      - name: DB_USER
        valueFrom:
          secretKeyRef:
            name: db-secret
            key: username
```

Codificação em base64 não é criptografia: qualquer pessoa com acesso de leitura ao Secret decodifica o valor trivialmente. Nunca versione um Secret com valores reais em texto no Git; veja [segredos no Git](../../../learn/secrets-management/secrets-in-git/) para as estratégias usadas neste notebook.

---

## Requests e limits de recursos

```yaml
containers:
  - name: app
    resources:
      requests:
        cpu: "100m"
        memory: "128Mi"
      limits:
        cpu: "500m"
        memory: "512Mi"
```

`requests` é o valor reservado para o container na decisão de agendamento, não um limite superior. `limits` é o teto de consumo: ultrapassar o limite de memória causa `OOMKilled`; ultrapassar o limite de CPU causa apenas throttling, sem encerrar o processo.

---

## Probes de readiness e liveness

```yaml
containers:
  - name: app
    livenessProbe:
      httpGet:
        path: /health
        port: 8000
      initialDelaySeconds: 30
      periodSeconds: 10
    readinessProbe:
      httpGet:
        path: /ready
        port: 8000
      initialDelaySeconds: 5
```

A liveness probe reinicia o container quando falha repetidamente; a readiness probe apenas remove o Pod da lista de endpoints prontos de um Service, sem reiniciá-lo. Não use o mesmo endpoint com a mesma semântica para as duas: uma dependência externa lenta não deveria derrubar a liveness, só a readiness. Veja [startup, readiness e liveness probes](../../../operations/checklists/application-readiness/#startup-readiness-e-liveness-probes) para a diferença completa entre as três probes.

---

## Expor via HTTPRoute (Gateway API)

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: myapp-route
spec:
  parentRefs:
    - name: <gateway>
  hostnames:
    - app.example.com
  rules:
    - backendRefs:
        - name: myapp-svc
          port: 80
```

Este notebook usa a Gateway API (não o recurso `Ingress` clássico) como forma padrão de expor serviços via HTTP; veja [configurar o Traefik com Gateway API](../../../guides/tasks/networking/configure-traefik-gateway-api/) para o procedimento completo, incluindo a criação do `Gateway` referenciado em `parentRefs`. O `Ingress` clássico ainda é suportado pelo Kubernetes e por outros clusters que não adotaram a Gateway API, mas não é o caminho documentado neste notebook.

---

## PersistentVolumeClaim

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-pvc
spec:
  storageClassName: longhorn
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
```

```yaml
# Trecho do container que monta o PVC acima (excerto, não um manifesto completo)
containers:
  - volumeMounts:
      - name: data
        mountPath: /data
volumes:
  - name: data
    persistentVolumeClaim:
      claimName: data-pvc
```

`storageClassName: longhorn` pressupõe o Longhorn já instalado como provisionador (veja [instalar o Longhorn](../../../guides/tasks/storage/install-longhorn/)); troque pelo nome da `StorageClass` real do cluster de destino. Veja [modelo de armazenamento do Kubernetes](../../../learn/storage/kubernetes-storage-model/) para como PVC, `StorageClass` e `PersistentVolume` se relacionam.

---

## Labels e selectors

```yaml
metadata:
  labels:
    app: myapp
    version: v1
    env: prod
```

```yaml
selector:
  matchLabels:
    app: myapp
    env: prod
  matchExpressions:
    - key: version
      operator: In
      values: ["v1", "v2"]
```

Labels organizam e identificam recursos; selectors os filtram. `matchLabels` exige correspondência exata de todos os pares chave-valor listados; `matchExpressions` permite condições mais ricas, como `In`, `NotIn`, `Exists` e `DoesNotExist`. Um `selector` combinando os dois exige que todas as condições sejam satisfeitas ao mesmo tempo.
