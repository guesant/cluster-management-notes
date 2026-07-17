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

1. Entender a [arquitetura do Kubernetes e do K3s](concepts/kubernetes-and-k3s.md) e definir o [planejamento do cluster](concepts/planning.md).
2. Preparar os hosts com [firewall](preparation/firewall.md), [hardening do SSH](preparation/ssh.md) e [Fail2Ban](preparation/fail2ban.md).
3. Criar o [primeiro servidor](cluster/first-server.md).
4. Configurar [Gateway API e Traefik](networking/gateway-api-and-traefik.md).
5. Se a topologia for multinó, adicionar os demais [servidores](cluster/add-server.md) e [agentes](cluster/add-agent.md).
6. Configurar o [acesso remoto](security/remote-access.md) e criar identidades com as permissões necessárias em [RBAC](security/identity-and-rbac.md).
7. Instalar os serviços necessários: [cert-manager](services/cert-manager.md), [Longhorn](services/longhorn.md) e [Argo CD](gitops/argo-cd.md).
8. Conectar o [repositório GitOps](gitops/bootstrap.md) e, opcionalmente, configurar a sincronização de segredos com o [Infisical](gitops/infisical.md).
9. Modelar as [NetworkPolicies](networking/network-policies.md) em homologação e permitir explicitamente os fluxos necessários.
10. Definir os procedimentos de [backup, atualização e remoção de nós](operations/cluster-maintenance.md).
11. Concluir com o [checklist operacional](operations/checklist.md).

## Conteúdo por categoria

### Fundamentos

- [Kubernetes e K3s](concepts/kubernetes-and-k3s.md): estado desejado, reconciliação, recursos principais e papéis dos nós.
- [Planejamento e segredos](concepts/planning.md): topologia, endpoint da API, quorum, token e requisitos de rede.

### Preparação dos hosts

- [Firewall](preparation/firewall.md): exposição de portas, UFW e observações sobre Docker.
- [Hardening do SSH](preparation/ssh.md): preparação, configuração segura e validação do acesso.
- [Fail2Ban](preparation/fail2ban.md): bloqueio progressivo e validação da jail do SSH.

### Criação do cluster

- [Primeiro servidor](cluster/first-server.md): bootstrap de um cluster de nó único ou do primeiro manager.
- [Adicionar servidor](cluster/add-server.md): expansão do control plane e quorum do etcd.
- [Adicionar agente](cluster/add-agent.md): inclusão de nós destinados aos workloads.

### Rede e segurança

- [Gateway API e Traefik](networking/gateway-api-and-traefik.md): entrada e roteamento de tráfego.
- [NetworkPolicy](networking/network-policies.md): isolamento e liberação explícita dos fluxos entre workloads.
- [Acesso remoto](security/remote-access.md): kubeconfig administrativo e conexão da estação à API.
- [Identidade, autenticação e RBAC](security/identity-and-rbac.md): credenciais individuais, permissões e revogação.

### Serviços

- [cert-manager](services/cert-manager.md): emissão e renovação de certificados.
- [Longhorn](services/longhorn.md): armazenamento persistente distribuído.

### GitOps e segredos

- [Argo CD](gitops/argo-cd.md): instalação e acesso inicial ao controlador GitOps.
- [Bootstrap GitOps](gitops/bootstrap.md): conexão do repositório e Application raiz.
- [Infisical](gitops/infisical.md): sincronização de segredos para o Kubernetes.

### Operação e referência

- [Backup, atualização e remoção](operations/cluster-maintenance.md): manutenção do ciclo de vida do cluster.
- [Checklist operacional](operations/checklist.md): verificações antes de concluir a implantação.
- [Ferramentas de linha de comando](reference/command-line-tools.md): kubectl, Helm, Argo CD CLI e longhornctl.
- [Templates copiáveis](reference/templates.md): estrutura GitOps e componentes opcionais.
