---
title: Kubernetes
sidebar:
  order: 6
---

## Verificar o status do cluster

```bash
kubectl cluster-info
kubectl get nodes
kubectl top nodes  # CPU e memória de cada nó
```

**Quando usar:** um health check geral, para confirmar se a API está respondendo.

**Considerações:**

- `cluster-info` mostra o endereço do control plane e dos serviços de sistema principais.
- `get nodes` lista os nós e seu estado (`Ready`, `NotReady`).
- `top nodes` exige o metrics-server instalado no cluster; sem ele, o comando falha.

---

## Listar Pods e seu status

```bash
# Todos os namespaces
kubectl get pods -A

# Namespace específico
kubectl get pods -n default

# Com mais detalhes (inclui IP e nó)
kubectl get pods -o wide

# Apenas Pods fora de Running
kubectl get pods --field-selector=status.phase!=Running
```

**Quando usar:** ver quais Pods estão rodando, ou encontrar os que travaram ou falharam.

**Considerações:**

- `-A` lista Pods de todos os namespaces de uma vez.
- `-o wide` acrescenta colunas como IP do Pod e nó onde ele está agendado.
- `--field-selector` filtra pelo campo de status, útil para isolar Pods problemáticos em um cluster grande.

---

## Ver logs de um Pod

```bash
# Logs atuais
kubectl logs <pod-name>

# Acompanhar em tempo real
kubectl logs -f <pod-name>

# Últimas 100 linhas
kubectl logs <pod-name> --tail=100

# Container específico, quando o Pod tem mais de um
kubectl logs <pod-name> -c <container-name>

# Logs do container anterior, depois de um crash
kubectl logs <pod-name> --previous
```

**Quando usar:** depurar uma aplicação, ou entender o que causou uma falha.

**Considerações:**

- Por padrão, `kubectl logs` mostra apenas stdout/stderr do container principal.
- `-f` segue os logs em tempo real, como `tail -f`.
- `--previous` é a forma correta de ver os logs de um container que já reiniciou, já que os logs do container anterior não aparecem no comando padrão.

---

## Descrever um Pod

```bash
kubectl describe pod <pod-name>

# Namespace específico
kubectl describe pod <pod-name> -n myapp

# Só a seção de eventos recentes
kubectl describe pod <pod-name> | grep -A 10 Events:
```

**Quando usar:** ver detalhes de configuração, ou entender por que um Pod não iniciou (erro de pull de imagem, por exemplo).

**Considerações:**

- A saída inclui volumes montados, variáveis de ambiente, imagem usada e requests/limits de recursos.
- A seção `Events` mostra o histórico recente do Pod (falhas de pull, reinícios, falhas de probe) e costuma ser o primeiro lugar a olhar em um diagnóstico.

---

## Executar um comando dentro de um Pod

```bash
# Shell interativo
kubectl exec -it <pod-name> -- /bin/bash

# Comando único, sem shell interativo
kubectl exec <pod-name> -- env

# Container específico, quando o Pod tem mais de um
kubectl exec -it <pod-name> -c <container-name> -- /bin/bash
```

**Quando usar:** depurar o estado interno de um Pod, ou inspecionar seu filesystem.

**Considerações:**

- `-it` combina modo interativo e alocação de TTY, necessário para abrir um shell utilizável.
- O `--` separa as flags do `kubectl` do comando que será executado dentro do container.
- O container precisa ter o binário desejado instalado; imagens mínimas (como as baseadas em `distroless`) podem não ter `/bin/bash` nem `/bin/sh`.

---

## Port-forward para um Pod

```bash
# localhost:3000 encaminhado para container:8080
kubectl port-forward <pod-name> 3000:8080

# Escutando em todas as interfaces, não só localhost
kubectl port-forward <pod-name> 3000:8080 --address 0.0.0.0

# Contra um Service, forma mais comum
kubectl port-forward svc/<service-name> 3000:8080
```

**Quando usar:** acessar um serviço interno via localhost para depuração, sem expô-lo publicamente.

**Considerações:**

- Por padrão, o `port-forward` escuta apenas em `127.0.0.1`.
- `--address 0.0.0.0` expõe a porta encaminhada em todas as interfaces de rede da máquina local; isso amplia quem pode acessar o serviço encaminhado, então use com o mesmo cuidado que se daria a qualquer outra porta exposta.
- O comando bloqueia o terminal enquanto ativo; rode em segundo plano com `&` se precisar continuar usando o mesmo terminal.

---

## Acessar um serviço interno do cluster

```bash
# DNS interno, de dentro de um Pod
curl http://<service-name>:<port>

# FQDN completo
curl http://<service-name>.<namespace>.svc.cluster.local:<port>

# Port-forward a partir do host
kubectl port-forward svc/<service-name> 8080:80
# Depois: curl http://localhost:8080
```

**Quando usar:** testar conectividade entre serviços dentro do cluster, ou depurar sem expor nada externamente.

**Considerações:**

- O FQDN completo de um Service segue o padrão `<service>.<namespace>.svc.cluster.local`.
- De dentro de um Pod no mesmo namespace, o namespace pode ser omitido no nome.
- O CoreDNS resolve esses nomes automaticamente; se a resolução falhar, veja [testar resolução DNS interna do K3s](../dns/#testar-resolução-dns-interna-do-k3s).

---

## Verificar CPU e memória de um Pod

```bash
# Um Pod específico
kubectl top pod <pod-name>

# Todos os Pods, todos os namespaces
kubectl top pods -A

# Namespace específico
kubectl top pods -n myapp

# Ordenados por uso de memória
kubectl top pods --sort-by=memory
```

**Quando usar:** diagnosticar um `OOMKilled`, ou identificar throttling de CPU.

**Considerações:**

- Exige o metrics-server instalado no cluster.
- Mostra o uso atual, não uma série histórica; para tendência ao longo do tempo, use o Prometheus (veja [observabilidade e alertas](../../../operations/observability/observability-and-alerting/)).

---

## Ver requests e limits de recursos

```bash
# Direto do manifesto
kubectl get pod <pod-name> -o yaml | grep -A 5 resources:

# Ou via describe
kubectl describe pod <pod-name> | grep -A 3 "Limits\|Requests"
```

**Quando usar:** verificar se um Pod tem limites de recursos definidos, como prevenção contra OOM ou throttling inesperado.

**Considerações:**

- `requests` é o valor reservado para o Pod na decisão de agendamento; não é um limite superior.
- `limits` é o teto que o Pod pode consumir; ultrapassar o limite de memória causa `OOMKilled`, enquanto ultrapassar o limite de CPU causa apenas throttling, não término do processo.
