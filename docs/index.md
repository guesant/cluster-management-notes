# cluster-management-notes

Minhas anotações sobre como criar e operar clusters K3s de nó único (*single-node*) ou multinó (*multi-node*), reunindo conceitos, melhores práticas, guias passo a passo e scripts reutilizáveis.

!!! note
    As anotações deste guia foram elaboradas e revisadas com o apoio de inteligência artificial, especificamente o ChatGPT. Alguns scripts e outros conteúdos deste repositório também podem ter sido criados ou modificados com auxílio de IA. Valide o código, os comandos, as versões e as decisões de segurança de acordo com o seu ambiente antes de utilizá-los.

!!! danger
    Execute primeiro em um ambiente de teste. Os comandos alteram autenticação SSH, firewall, serviços do sistema e componentes do cluster. Mantenha uma sessão SSH funcional aberta durante mudanças de acesso e tenha acesso ao console da máquina antes de aplicar regras remotamente.

## Comece por aqui

- [Ensaio: cluster K3s](guides/k3s.md): roteiro com caminho comum, escolha de topologia, checkpoints e módulos opcionais.
- [Escopo, convenções e versões](reference/conventions.md): premissas adotadas pelos comandos e versões usadas como referência.

## Consulte por tema

- [Fundamentos do Kubernetes](k8s/concepts.md) e [arquitetura do K3s](k8s/k3s/architecture.md).
- [Segurança dos hosts](security/hosts/firewall.md).
- [Rede Kubernetes](k8s/networking/gateway-api-and-traefik.md), [segurança e acesso](k8s/security/remote-access.md) e [extensões](k8s/extensions/cert-manager.md).
- [GitOps com Argo CD](strategies/deployment/argo-cd.md) e [gestão de segredos com Infisical](strategies/secrets/infisical.md).
- [Ferramentas de linha de comando](reference/command-line-tools.md).
