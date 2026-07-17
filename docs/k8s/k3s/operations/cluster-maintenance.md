# Backup, atualização e remoção

## Snapshot do etcd

O etcd é o datastore consistente usado pelo control plane para guardar o estado da API Kubernetes: objetos, configurações, metadados e Secrets. Em um cluster com etcd embarcado, os managers mantêm cópias coordenadas desse estado e só podem confirmar mudanças enquanto existe quorum. Com três managers, o cluster tolera a indisponibilidade de um membro; adicionar apenas um quarto membro não aumenta essa tolerância e amplia a quantidade de membros necessários para o quorum.

Um snapshot do etcd permite recuperar o estado Kubernetes, mas não contém os dados gravados dentro dos volumes Longhorn, arquivos externos ao cluster nem imagens de containers. Por isso, snapshot do etcd, backup dos volumes e cópia segura do token do K3s são proteções diferentes e todas podem ser necessárias para uma restauração completa.

Em clusters com etcd embarcado, crie e liste um snapshot antes de alterações:

> **Executar em:** um nó manager com etcd embarcado, como `root`.

```bash
k3s etcd-snapshot save --name "manual-$(date +%Y%m%d-%H%M%S)"
k3s etcd-snapshot list
```

Copie os snapshots e o token de servidor para armazenamento externo. Um snapshot preso ao mesmo host não protege contra perda do nó ou do disco. Consulte o [procedimento oficial de backup e restauração](https://docs.k3s.io/datastore/backup-restore).

## Atualização

1. Leia as notas da versão e verifique a compatibilidade dos componentes.
2. Crie e copie um snapshot.
3. Atualize um servidor por vez e valide o cluster entre os nós.
4. Atualize os agentes depois dos servidores.

Como a configuração está em `/etc/rancher/k3s/config.yaml`, a atualização não depende de repetir todos os argumentos:

> **Executar em:** nó manager que está sendo atualizado, como `root`.

```bash
K3S_VERSION=""
while [[ -z "${K3S_VERSION}" ]]; do
  read -r -p "Versão exata do K3s que será instalada: " K3S_VERSION
done

curl -sfL https://get.k3s.io \
  | INSTALL_K3S_VERSION="${K3S_VERSION}" sh -s - server
```

Nos agents, use a mesma versão e execute:

> **Executar em:** nó agent que está sendo atualizado, como `root`.

```bash
K3S_VERSION=""
while [[ -z "${K3S_VERSION}" ]]; do
  read -r -p "Versão exata do K3s que será instalada: " K3S_VERSION
done

curl -sfL https://get.k3s.io \
  | INSTALL_K3S_VERSION="${K3S_VERSION}" sh -s - agent
```

Em caso de falha, pare e siga o [procedimento oficial de rollback](https://docs.k3s.io/upgrades/roll-back); não remova o banco de dados manualmente sem um snapshot válido e uma janela de manutenção.

## Remoção de nó

Antes de remover um agente ou servidor que hospeda workloads:

> **Executar em:** qualquer máquina com `KUBECONFIG` e acesso administrativo à API.

```bash
read -r -p "Nome do nó que será removido: " K3S_NODE_NAME
kubectl cordon "${K3S_NODE_NAME}"
kubectl drain "${K3S_NODE_NAME}" \
  --ignore-daemonsets \
  --delete-emptydir-data
```

!!! danger
    Confirme a réplica dos dados e o quorum do etcd antes de remover um servidor. Não execute o desinstalador no último servidor a menos que deseje apagar o cluster.

No nó removido, execute o desinstalador correspondente:

> **Executar em:** nó agent que será removido, como `root`.

```bash
/usr/local/bin/k3s-agent-uninstall.sh
```

> **Executar em:** nó manager que será removido, como `root`.

```bash
/usr/local/bin/k3s-uninstall.sh
```

Por fim, remova o objeto do cluster, se ainda existir:

> **Executar em:** qualquer máquina com `KUBECONFIG` e acesso administrativo à API.

```bash
read -r -p "Nome do nó que será removido do Kubernetes: " K3S_NODE_NAME
kubectl delete node "${K3S_NODE_NAME}"
```
