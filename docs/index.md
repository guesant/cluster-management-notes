# cluster-management-notes

Minhas anotações sobre como criar e operar clusters K3s de nó único (*single-node*) ou multinó (*multi-node*), reunindo conceitos, melhores práticas, guias passo a passo e scripts reutilizáveis.

!!! note
    As anotações deste guia foram elaboradas e revisadas com o apoio de inteligência artificial, especificamente o ChatGPT. Alguns scripts e outros conteúdos deste repositório também podem ter sido criados ou modificados com auxílio de IA. Valide o código, os comandos, as versões e as decisões de segurança de acordo com o seu ambiente antes de utilizá-los.

!!! danger
    Execute primeiro em um ambiente de teste. Os comandos alteram autenticação SSH, firewall, serviços do sistema e componentes do cluster. Mantenha uma sessão SSH funcional aberta durante mudanças de acesso e tenha acesso ao console da máquina antes de aplicar regras remotamente.

## Escopo e premissas

- Hosts Debian ou Ubuntu com `systemd`.
- Arquiteturas `amd64` e `arm64`.
- Comandos de administração do host executados como `root`. Quando estiver em uma conta comum, abra antes um shell com `sudo -i`.
- Nomes de nós, endereços IP, nomes DNS, portas e demais parâmetros do ambiente são solicitados pelos blocos interativos antes da execução.
- O kubeconfig administrativo do K3s concede acesso total ao cluster e deve ser armazenado com permissão `0600`.
- As versões abaixo são os valores padrão oferecidos pelos prompts para facilitar o copia e cola. Elas são referências, não uma matriz de compatibilidade homologada por este repositório; informe outra versão quando necessário e valide o conjunto em homologação antes de atualizar produção.

!!! note
    Nos prompts, o valor entre colchetes é usado quando Enter é pressionado sem digitar nada. Os blocos interativos encapsulados usam `bash <<'EOF'`. Não acrescente `-c`: essa opção exige o script como argumento, enquanto o heredoc entrega o script pela entrada padrão. Dentro desses blocos, os prompts leem de `/dev/tty` para não consumir as próximas linhas do próprio heredoc.

| Componente | Versão padrão usada ou sugerida |
| --- | --- |
| K3s | `v1.36.1+k3s1` |
| Gateway API, canal Standard | `v1.5.1` |
| cert-manager | `v1.20.0` |
| Longhorn e longhornctl | `1.12.0` |
| Chart Helm do Argo CD | `10.1.3` |
| Chart CloudNativePG / operator | `0.29.0` / `1.30.0` |
| Chart Infisical Secrets Operator | `0.11.3` |

### Convenções de execução

Cada bloco shell informa onde deve ser executado:

- **nó alvo:** host Linux que será alterado; pode ser manager, agent ou uma máquina fora do cluster;
- **nó manager:** nó K3s com função server/control-plane;
- **nó agent:** nó K3s com função agent/worker;
- **máquina com KUBECONFIG:** qualquer manager ou estação administrativa que tenha `kubectl`, acesso à API e um kubeconfig com as permissões necessárias;
- **estação administrativa:** máquina de origem usada para SSH, túneis ou instalação de CLIs; não precisa pertencer ao cluster.

## Ordem recomendada

1. Entender os [conceitos do Kubernetes](k8s/concepts.md), a [arquitetura do K3s](k8s/k3s/architecture.md) e definir o [planejamento do cluster](k8s/k3s/planning.md).
2. Preparar os hosts com [firewall](security/hosts/firewall.md), [hardening do SSH](security/hosts/ssh.md) e [Fail2Ban](security/hosts/fail2ban.md).
3. Criar o [primeiro servidor](k8s/k3s/cluster/first-server.md).
4. Configurar [Gateway API e Traefik](k8s/k3s/networking/gateway-api-and-traefik.md).
5. Se a topologia for multinó, adicionar os demais [servidores](k8s/k3s/cluster/add-server.md) e [agentes](k8s/k3s/cluster/add-agent.md).
6. Configurar o [acesso remoto](k8s/k3s/security/remote-access.md) e criar identidades com as permissões necessárias em [RBAC](k8s/k3s/security/identity-and-rbac.md).
7. Instalar os serviços necessários: [cert-manager](k8s/k3s/services/cert-manager.md), [Longhorn](k8s/k3s/services/longhorn.md) e [Argo CD](strategies/deployment/argo-cd.md).
8. Conectar o [repositório GitOps](strategies/deployment/gitops-bootstrap.md) e, opcionalmente, configurar a sincronização de segredos com o [Infisical](strategies/secrets/infisical.md).
9. Modelar as [NetworkPolicies](k8s/k3s/networking/network-policies.md) em homologação e permitir explicitamente os fluxos necessários.
10. Definir os procedimentos de [backup, atualização e remoção de nós](k8s/k3s/operations/cluster-maintenance.md).
11. Concluir com o [checklist operacional](k8s/k3s/operations/checklist.md).

## Conteúdo por categoria

### Segurança dos hosts

- [Firewall](security/hosts/firewall.md): configuração do UFW para os hosts do cluster.
- [Portas publicadas pelo Docker](security/hosts/docker-published-ports.md): exposição de portas pelo Docker e interação com o firewall do host.
- [Hardening do SSH](security/hosts/ssh.md): preparação, configuração segura e validação do acesso.
- [Fail2Ban](security/hosts/fail2ban.md): bloqueio progressivo e validação da jail do SSH.

### Kubernetes e K3s

- [Conceitos do Kubernetes](k8s/concepts.md): estado desejado, reconciliação e recursos principais.
- [Arquitetura do K3s](k8s/k3s/architecture.md): papéis dos nós, control plane e datastore.
- [Planejamento e segredos](k8s/k3s/planning.md): topologia, endpoint da API, quorum, token e requisitos de rede.
- [Primeiro servidor](k8s/k3s/cluster/first-server.md): bootstrap de um cluster de nó único ou do primeiro manager.
- [Adicionar servidor](k8s/k3s/cluster/add-server.md): expansão do control plane e quorum do etcd.
- [Adicionar agente](k8s/k3s/cluster/add-agent.md): inclusão de nós destinados aos workloads.
- [Gateway API e Traefik](k8s/k3s/networking/gateway-api-and-traefik.md): entrada e roteamento de tráfego.
- [NetworkPolicy](k8s/k3s/networking/network-policies.md): isolamento e liberação explícita dos fluxos entre workloads.
- [Acesso remoto](k8s/k3s/security/remote-access.md): kubeconfig administrativo e conexão da estação à API.
- [Identidade, autenticação e RBAC](k8s/k3s/security/identity-and-rbac.md): credenciais individuais, permissões e revogação.
- [cert-manager](k8s/k3s/services/cert-manager.md): emissão e renovação de certificados.
- [Longhorn](k8s/k3s/services/longhorn.md): armazenamento persistente distribuído.
- [Backup, atualização e remoção](k8s/k3s/operations/cluster-maintenance.md): manutenção do ciclo de vida do cluster.
- [Checklist operacional](k8s/k3s/operations/checklist.md): verificações antes de concluir a implantação.
- [Ferramentas de linha de comando](k8s/tools.md): kubectl, Helm, Argo CD CLI e longhornctl.

### Estratégias de deploy

- [Argo CD](strategies/deployment/argo-cd.md): instalação e acesso inicial ao controlador GitOps.
- [Bootstrap GitOps](strategies/deployment/gitops-bootstrap.md): conexão do repositório e Application raiz.
- [Templates copiáveis](strategies/deployment/templates.md): estrutura GitOps e componentes opcionais.

### Estratégias de secrets

- [Infisical](strategies/secrets/infisical.md): sincronização de segredos para o Kubernetes.
