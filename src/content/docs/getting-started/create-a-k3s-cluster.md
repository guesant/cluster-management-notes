---
title: Criar um cluster K3s
description: Roteiro com caminho comum, escolha de topologia, checkpoints e módulos opcionais para criar um cluster K3s.
sidebar:
  order: 1
---

Este ensaio organiza o conteúdo existente em um único percurso para criar um cluster K3s de nó único ou multinó. Ele apresenta as decisões, a ordem das etapas e os pontos de verificação; os conceitos, comandos e scripts permanecem nas páginas temáticas indicadas.

## Como usar este roteiro

Cada fase é identificada como:

- **Obrigatória:** necessária para chegar a um cluster funcional no perfil escolhido;
- **Recomendada:** pode não impedir a instalação, mas faz parte do percurso operacional sugerido;
- **Opcional ou condicional:** execute somente quando o requisito indicado existir.

Conclua o checkpoint de uma fase antes de avançar. Quando uma página temática apresentar alternativas, retorne a este roteiro depois de executar apenas a opção correspondente ao seu ambiente.

## Escolha o perfil do cluster

Use o primeiro servidor como ponto de partida comum e escolha uma das ramificações:

| Perfil | Nós do cluster | Expansão depois do primeiro servidor |
| --- | --- | --- |
| Nó único | Um servidor | Não adicionar outros nós |
| Servidor com agentes | Um servidor e um ou mais agentes | Adicionar somente agentes |
| HA com etcd embarcado | Três ou mais servidores em quantidade ímpar | Adicionar servidores; agentes são opcionais |

Um servidor com agentes distribui workloads, mas mantém um único nó de control plane. Para HA com etcd embarcado, siga a orientação de quorum do [planejamento do cluster](planning.md) e não encerre a expansão com apenas dois servidores.

Todos os perfis pedem um host ou IP estável para a API. Este roteiro usa esse endereço na instalação e no kubeconfig, mas ainda não contém um procedimento para provisionar DNS, IP virtual ou load balancer. Resolva essa dependência antes da instalação; no perfil HA, o endpoint também precisa continuar disponível quando um servidor falhar.

## 1. Planeje o cluster

**Obrigatória para todos os perfis.**

1. Confirme o [escopo, as convenções e as versões de referência](../reference/conventions.md).
2. Leia os [conceitos do Kubernetes](../concepts/kubernetes.md) e a [arquitetura do K3s](../concepts/k3s-architecture.md).
3. Siga o [planejamento do cluster](planning.md) para definir nomes, endereços, endpoint da API, quantidade de servidores e custódia do token.
4. Escolha um dos perfis acima.
5. Decida se o ambiente terá workloads persistentes e quais módulos opcionais serão necessários depois do cluster-base.

**Checkpoint:** a topologia, os nomes e endereços dos nós, o endpoint estável da API e o local seguro para guardar o token estão definidos.

## 2. Prepare os hosts e a estação administrativa

**Obrigatória:** configure o [firewall básico dos hosts](../hosts/firewall.md), aplique as [regras de rede dos nós K3s](../kubernetes/k3s/host-firewall.md) de acordo com a topologia e prepare as [ferramentas de linha de comando](../reference/command-line-tools.md) na estação que administrará o cluster.

**Recomendada:** aplique o [hardening do SSH](../hosts/ssh-hardening.md) e configure o [Fail2Ban](../hosts/fail2ban.md) conforme o modelo de acesso aos hosts.

**Condicional:** consulte [portas publicadas pelo Docker](../hosts/docker-published-ports.md) somente nos hosts em que Docker estiver instalado e houver containers com portas publicadas. Essa etapa não é um requisito do K3s.

**Checkpoint:** os hosts se comunicam pelas portas necessárias ao perfil escolhido, o acesso administrativo aos hosts funciona e as ferramentas necessárias estão disponíveis na estação administrativa.

## 3. Inicialize o primeiro servidor

**Obrigatória para todos os perfis.**

Execute o passo a passo do [primeiro servidor K3s](first-server.md). Essa mesma etapa encerra a instalação do perfil de nó único e inicializa o control plane dos perfis multinó.

**Checkpoint:** o serviço K3s está ativo, o primeiro nó aparece como `Ready` e os Pods do sistema foram listados sem erro na validação da página.

## 4. Configure o acesso administrativo

**Recomendada imediatamente após o bootstrap e necessária para continuar a partir de uma estação administrativa.**

1. Configure o [acesso remoto ao cluster](../kubernetes/security/remote-access.md).
2. Mantenha o kubeconfig administrativo restrito e use [identidade, autenticação e RBAC](../kubernetes/security/identity-and-rbac.md) quando outras pessoas ou automações não precisarem de acesso total.

**Checkpoint:** a estação administrativa alcança a API pelo endpoint estável e `kubectl` confirma o acesso esperado.

## 5. Faça o backup inicial

**Recomendada antes de expandir o cluster ou instalar módulos.**

Siga a seção de snapshot em [backup, atualização e remoção](../operations/k3s-cluster-maintenance.md). Guarde externamente o snapshot e o token, considerando separadamente os dados de volumes quando eles passarem a existir.

**Checkpoint:** o snapshot inicial foi listado, copiado para fora do nó e associado ao token necessário para uma restauração.

## 6. Expanda conforme o perfil escolhido

**Condicional aos perfis multinó.**

- **Nó único:** não adicione nós; avance para a decisão de armazenamento.
- **Um servidor com agentes:** siga [adicionar agente](../kubernetes/k3s/add-agent.md) em cada worker desejado.
- **HA com etcd embarcado:** siga [adicionar servidor](../kubernetes/k3s/add-server.md) até obter pelo menos três servidores em quantidade ímpar. Depois, [adicione agentes](../kubernetes/k3s/add-agent.md) somente se quiser separar ou ampliar a capacidade de execução dos workloads.

Não inicie essa fase enquanto o endpoint estável da API ainda depender exclusivamente de uma solução não definida, especialmente no perfil HA.

**Checkpoint:** todos os nós planejados aparecem como `Ready`; no perfil HA, a quantidade de servidores atende à decisão de quorum.

## 7. Decida o armazenamento

**Decisão obrigatória; instalação condicional.**

O passo a passo do primeiro servidor desabilita `local-storage`. Portanto, não presuma que o cluster possui uma classe de armazenamento padrão:

- se os workloads não usam volumes persistentes, registre essa decisão e prossiga sem instalar um provisionador;
- se usam PVCs, escolha e configure um provisionador antes de implantá-los;
- se a escolha for Longhorn, siga a página do [Longhorn](../kubernetes/extensions/longhorn.md), incluindo a preparação dos nós e as verificações indicadas nela.

**Checkpoint:** existe uma classe de armazenamento validada para os workloads persistentes ou está registrado que o cluster não receberá PVCs nesta etapa.

## 8. Escolha os módulos de plataforma

Os módulos abaixo não são requisitos equivalentes ao cluster-base. Instale somente os que atendem ao ambiente, respeitando a ordem das dependências escolhidas.

### Publicação e certificados

**Opcional.** Configure [Gateway API e Traefik](../kubernetes/networking/gateway-api-and-traefik.md) quando precisar publicar serviços. Instale o [cert-manager](../kubernetes/extensions/cert-manager.md) quando quiser automatizar a emissão e renovação dos certificados descritos no percurso.

**Checkpoint:** os controllers escolhidos estão saudáveis e os recursos de teste ou validação indicados em suas páginas funcionam.

### GitOps

**Opcional.** Para administrar aplicações a partir do Git:

1. instale o [Argo CD](../guides/deployment/argo-cd.md);
2. execute o [bootstrap do repositório GitOps](../guides/deployment/gitops-bootstrap.md);
3. escolha apenas os [templates copiáveis](../guides/deployment/templates.md) que serão usados.

**Checkpoint:** a Application raiz e somente as Applications selecionadas foram criadas, sincronizadas e verificadas.

### Isolamento com NetworkPolicy

**Opcional e dependente dos fluxos reais das aplicações.** Revise [NetworkPolicies](../kubernetes/networking/network-policies.md) antes de ativar isolamento. Se usar os templates GitOps dessa página, faça esta etapa somente depois de concluir o bootstrap do Argo CD e versionar as políticas revisadas.

**Checkpoint:** as políticas foram validadas em homologação, os fluxos necessários continuam funcionando e a auditoria indicada na página não encontrou regras amplas ou baselines ausentes.

### Sincronização de segredos

**Opcional e condicionada à compatibilidade.** Use a estratégia com [Infisical](../guides/secrets/infisical.md) somente depois de confirmar que as versões do Kubernetes/K3s e do operator estão dentro de uma combinação suportada ou validada em homologação. A versão de K3s sugerida atualmente pelo guia está fora da matriz declarada na página do Infisical; não trate esse módulo como etapa automática do percurso.

Quando usar os templates, conclua primeiro o bootstrap GitOps e respeite a ordem entre operator, CRDs, credencial manual e recursos de sincronização descrita na página.

**Checkpoint:** a compatibilidade foi aceita explicitamente, o operator e seus CRDs estão saudáveis e a sincronização foi validada sem expor os valores dos Secrets.

## 9. Encerre o bootstrap e passe à operação

**Recomendada para todos os perfis.**

Revise a [validação pós-instalação](../operations/k3s-post-install-checklist.md) somente para o núcleo e os módulos que escolheu. Depois, adote o [guia de operação contínua](../guides/operations-overview.md) para definir responsáveis, cadências, monitoramento, alertas, política de versões e testes de recuperação. Registre cada rotina ou mudança no [runbook de manutenção](../operations/maintenance-runbook.md) e use [backup, atualização e remoção](../operations/k3s-cluster-maintenance.md) como referência para snapshots, mudanças de versão e ciclo de vida dos nós.

**Checkpoint:** o cluster-base e cada módulo escolhido têm validação registrada, responsáveis e cadências definidos, backup compatível com seus dados e um caminho conhecido de manutenção.

## Fontes e leitura adicional

- [Quick-Start Guide — K3s](https://docs.k3s.io/quick-start): apresenta o fluxo oficial de instalação do primeiro servidor e de associação de agentes.
- [Requisitos de instalação — K3s](https://docs.k3s.io/installation/requirements): documenta sistemas suportados, recursos mínimos e comunicação de rede entre os nós.
- [HA com etcd embarcado — K3s](https://docs.k3s.io/datastore/ha-embedded): explica quorum, quantidade de servidores e inicialização de clusters altamente disponíveis.
- [Acesso ao cluster — K3s](https://docs.k3s.io/cluster-access): descreve o kubeconfig administrativo e o acesso à API a partir de outra máquina.
- [Backup e restauração do datastore — K3s](https://docs.k3s.io/datastore/backup-restore): referência para snapshots do etcd, token do servidor e procedimentos de recuperação.
