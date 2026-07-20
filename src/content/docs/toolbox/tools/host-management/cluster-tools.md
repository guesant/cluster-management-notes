---
title: Gerenciamento de hosts e clusters
description: Catálogo de instalação rápida para k9s, Lens, Rancher, Portainer, Cockpit e Headlamp, complementar à comparação conceitual em ferramentas de gerenciamento visual.
sidebar:
  order: 1
---

> **Para quem é:** operadores que já decidiram qual ferramenta visual usar e querem o comando de instalação, sem repetir a comparação entre elas.

Esta página é a referência rápida de instalação. Para entender as diferenças entre k9s, Lens, Rancher, Portainer e Headlamp (categoria, overhead, quando cada um se justifica), veja [ferramentas de gerenciamento visual](../../../../learn/tools/visual-management/); esta página não repete essa comparação, só os comandos.

## k9s

```bash
# Via Homebrew (Linux e macOS)
brew install derailed/k9s/k9s

# Via gerenciador de pacotes, quando empacotado pela distribuição
sudo apt install k9s
```

```bash
k9s
```

Dentro da TUI: `:pod`, `:deployment`, `:node` navegam entre tipos de recurso; `?` abre a ajuda; setas e Enter abrem detalhes e logs do item selecionado.

## Lens

Download na [página oficial](https://k8slens.dev/). O modelo de licenciamento do Lens mudou mais de uma vez desde que o projeto passou para a Mirantis, incluindo o fork comunitário OpenLens; confirme na documentação oficial qual edição está sendo instalada antes de adotar em um ambiente corporativo (veja a ressalva completa em [ferramentas de gerenciamento visual](../../../../learn/tools/visual-management/#lens-cliente-desktop-com-múltiplos-clusters)).

## Rancher

```bash
helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
helm install rancher rancher-latest/rancher \
  --namespace cattle-system --create-namespace \
  --version <versão-do-chart> \
  --set hostname=rancher.example.com
```

Fixe `--version` com uma versão específica do chart antes de instalar; sem isso, o Helm instala a versão mais recente do momento, o que torna a instalação não reprodutível. Confirme a versão atual nas [releases do chart](https://github.com/rancher/rancher/releases) antes de aplicar.

## Portainer

```bash
docker run -d \
  -p 127.0.0.1:9000:9000 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  portainer/portainer-ce:<versão-do-portainer>
```

Montar `/var/run/docker.sock` dentro do container dá ao Portainer controle equivalente a root sobre o host: qualquer processo com acesso a esse socket pode criar containers privilegiados e escapar do isolamento normal de containers. Trate o acesso ao Portainer com o mesmo cuidado que se daria a uma credencial administrativa do host, e não publique a porta além de `127.0.0.1` sem um motivo explícito. Fixe a tag da imagem (evite `:latest`); confirme a versão atual nas [releases do Portainer](https://github.com/portainer/portainer/releases).

## Cockpit

```bash
sudo apt install cockpit
```

Acesse em `https://localhost:9090` (ou o IP do host, se remoto). Diferente das demais ferramentas desta página, o Cockpit gerencia um host Linux individual, não um cluster: services via systemd, firewall, armazenamento e logs do sistema. Veja [segurança do host](../../../../operations/checklists/host-security/) para o que revisar antes de expor essa interface administrativa além de `localhost`.

## Headlamp

```bash
helm repo add headlamp https://kubernetes-sigs.github.io/headlamp/
helm install headlamp headlamp/headlamp \
  --namespace headlamp-system --create-namespace \
  --version <versão-do-chart>
```

O projeto foi doado à CNCF e hoje vive sob a organização `kubernetes-sigs`, não mais sob o nome antigo do mantenedor original (Kinvolk); confirme a versão do chart nas [releases do projeto](https://github.com/kubernetes-sigs/headlamp/releases) antes de instalar. Não exponha o dashboard publicamente sem autenticação: como qualquer painel administrativo do cluster, ele tem acesso a Secrets e à capacidade de criar ou excluir recursos.

## Escolher a ferramenta

| Caso | Ferramenta |
| --- | --- |
| CLI rápido, sem instalar nada no cluster | k9s |
| Desktop visual, múltiplos clusters | Lens |
| Múltiplos clusters heterogêneos, RBAC centralizado | Rancher |
| Docker/Swarm, não Kubernetes | Portainer |
| Administração de um host Linux individual, não um cluster | Cockpit |
| Dashboard web leve, um cluster único | Headlamp |

## Referências

- [k9s (repositório oficial)](https://github.com/derailed/k9s): instalação, atalhos e plugins.
- [Lens (documentação oficial)](https://docs.k8slens.dev/): edições disponíveis e licenciamento atual.
- [Rancher (documentação oficial)](https://ranchermanager.docs.rancher.com/): instalação e operação.
- [Portainer (documentação oficial)](https://docs.portainer.io/): instalação e integração com Docker/Kubernetes.
- [Cockpit](https://cockpit-project.org/): documentação oficial do projeto.
- [Headlamp (repositório oficial)](https://github.com/kubernetes-sigs/headlamp): projeto sandbox da CNCF, instalação via Helm.
