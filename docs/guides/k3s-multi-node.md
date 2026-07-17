# Ensaio: cluster K3s multinó

Este ensaio organiza o conteúdo existente em um percurso completo para um cluster K3s multinó. Os conceitos, comandos e scripts permanecem nas páginas temáticas indicadas em cada etapa.

1. Leia os [conceitos do Kubernetes](../k8s/concepts.md), a [arquitetura do K3s](../k8s/k3s/architecture.md) e o [planejamento do cluster](../k8s/k3s/planning.md).
2. Prepare os hosts seguindo as páginas de [firewall](../security/hosts/firewall.md), [portas publicadas pelo Docker](../security/hosts/docker-published-ports.md), [hardening do SSH](../security/hosts/ssh.md) e [Fail2Ban](../security/hosts/fail2ban.md).
3. Instale as [ferramentas de linha de comando](../k8s/tools.md) necessárias.
4. Execute o passo a passo do [primeiro servidor K3s](../k8s/k3s/cluster/first-server.md).
5. Expanda o cluster seguindo os passos para [adicionar servidores](../k8s/k3s/cluster/add-server.md) e [adicionar agentes](../k8s/k3s/cluster/add-agent.md).
6. Configure [Gateway API e Traefik](../k8s/k3s/networking/gateway-api-and-traefik.md) e revise as [NetworkPolicies](../k8s/k3s/networking/network-policies.md).
7. Configure o [acesso remoto](../k8s/k3s/security/remote-access.md) e as permissões em [RBAC](../k8s/k3s/security/identity-and-rbac.md).
8. Consulte os passos de instalação do [cert-manager](../k8s/k3s/services/cert-manager.md) e do [Longhorn](../k8s/k3s/services/longhorn.md).
9. Para GitOps, siga a instalação do [Argo CD](../strategies/deployment/argo-cd.md), o [bootstrap do repositório](../strategies/deployment/gitops-bootstrap.md) e os [templates copiáveis](../strategies/deployment/templates.md).
10. Para sincronização de segredos, consulte a estratégia com [Infisical](../strategies/secrets/infisical.md).
11. Finalize com os procedimentos de [backup, atualização e remoção](../k8s/k3s/operations/cluster-maintenance.md) e o [checklist operacional](../k8s/k3s/operations/checklist.md).
