---
title: Ferramentas e catálogos
sidebar:
  order: 3
---

Esta página é um índice para descobrir ferramentas que podem complementar a operação dos hosts, containers e clusters. A presença de uma ferramenta nesta lista não significa que ela faça parte da arquitetura recomendada nem que tenha sido homologada por este projeto.

Antes de adotar uma opção, identifique o problema que ela resolve e compare-a com o que já existe. Uma interface gráfica não cria uma fronteira de segurança adicional: quando recebe um kubeconfig administrativo, acesso ao socket do Docker ou uma ServiceAccount privilegiada, ela pode realizar as mesmas operações permitidas por essas credenciais.

## Critérios de avaliação

Registre pelo menos:

- finalidade, responsáveis e alternativa existente;
- modelo de execução: cliente local, serviço no host, componente dentro do cluster ou SaaS;
- credenciais, permissões, portas, agentes e volumes privilegiados necessários;
- dados enviados para serviços externos, telemetria, sincronização e política de privacidade;
- licença, custos atuais, limites do plano e dependência do fornecedor;
- compatibilidade, frequência de releases, política de segurança e procedimento de atualização;
- backup da configuração, desinstalação e impacto da indisponibilidade da própria ferramenta.

Use uma identidade individual de privilégio mínimo para avaliar clientes. Não entregue o kubeconfig administrativo, o socket `/var/run/docker.sock` ou credenciais de todos os clusters apenas para simplificar o primeiro acesso.

## Acesso remoto e administração dos hosts

| Ferramenta | Modelo | Onde pode ajudar | Pontos a avaliar |
| --- | --- | --- | --- |
| [OpenSSH](https://www.openssh.com/) | Cliente e servidor livres | Acesso remoto, túneis, cópia de arquivos e automação usando componentes amplamente disponíveis | Hardening, custódia das chaves, `known_hosts`, bastion e encaminhamentos permitidos |
| [Termius](https://termius.com/) | Cliente comercial para desktop e dispositivos móveis | Catálogo de hosts, SSH, SFTP e recursos de colaboração ou sincronização conforme o plano | Política do plano, armazenamento e sincronização de chaves, conta externa, telemetria e uso de cofres da equipe |
| [Cockpit](https://cockpit-project.org/) | Interface web livre executada no host | Estado do sistema, serviços, logs, armazenamento e tarefas administrativas comuns | Porta exposta, autenticação do sistema, elevação de privilégio e necessidade de uma interface web em cada host |

Termius e Cockpit são conveniências operacionais, não substitutos para identidade individual, SSH endurecido, firewall, logs de auditoria ou procedimentos reproduzíveis.

## Interfaces para Kubernetes

| Ferramenta | Modelo | Onde pode ajudar | Pontos a avaliar |
| --- | --- | --- | --- |
| [Lens](https://docs.k8slens.dev/k8slens/getting-started/) | Aplicação desktop com planos gratuitos e pagos | Navegação multi-cluster, recursos, logs, terminal, Helm e port-forward a partir de kubeconfigs | Condições do plano, Lens ID, localização dos kubeconfigs, integrações externas e permissões efetivas do contexto |
| [Headlamp](https://headlamp.dev/docs/latest/) | Aplicação desktop ou web in-cluster, open source e projeto CNCF Sandbox | Interface extensível para recursos Kubernetes, adaptada às permissões RBAC do usuário | Autenticação do modo web, publicação da interface, plugins, ServiceAccount e permissões de cada usuário |
| [K9s](https://k9scli.io/) | TUI local open source | Inspeção rápida de recursos, eventos, logs e operações permitidas pelo kubeconfig | Contexto ativo, atalhos ou plugins mutativos e exposição de Secrets no terminal ou histórico |
| [Rancher](https://ranchermanager.docs.rancher.com/getting-started/overview) | Plataforma web executada em Kubernetes | Administração e políticas para um ou vários clusters | Alta disponibilidade, identidade, backup, upgrades e o impacto de adicionar uma camada de gestão ao cluster |

Essas interfaces complementam `kubectl`; não substituem manifests versionados, revisão de mudanças ou GitOps. Para operações destrutivas, confirme cluster, namespace, identidade e diff fora da interface antes de prosseguir.

## Docker, Swarm e containers

| Ferramenta | Modelo | Onde pode ajudar | Pontos a avaliar |
| --- | --- | --- | --- |
| [Docker CLI e Compose](https://docs.docker.com/engine/cli/) | Clientes oficiais | Operação direta do Engine e de aplicações Compose, com configuração versionável | Contexto Docker, privilégios equivalentes a root, origem das imagens, Secrets e rollback |
| [Portainer](https://docs.portainer.io/start/intro) | Interface web Community ou Business | Administração de ambientes Docker, Docker Swarm e Kubernetes por servidor ou agente | Acesso ao socket/API, permissões dos agentes, exposição da interface, RBAC, backup e diferenças entre edições |
| [lazydocker](https://github.com/jesseduffield/lazydocker) | TUI local open source | Consulta interativa de containers, imagens, volumes, logs e estatísticas | Acesso ao daemon Docker, comandos mutativos e adequação para diagnóstico, não para estado desejado |

No Docker e no Swarm, acesso ao daemon geralmente permite criar containers privilegiados e controlar o host. Trate a API e o socket do Docker como acesso administrativo e nunca os publique sem uma fronteira de autenticação e autorização apropriada.

## Diagnóstico, segurança e recuperação

| Ferramenta | Finalidade | Limite importante |
| --- | --- | --- |
| [`cmctl`](https://cert-manager.io/docs/reference/cmctl/) | Validar a API do cert-manager, diagnosticar certificados e solicitar uma reemissão controlada | Não substitui alerta de expiração nem um teste ACME ponta a ponta |
| [Velero](https://velero.io/docs/) | Backup, restauração e migração de recursos Kubernetes e volumes por mecanismos suportados | Consistência de aplicações stateful e cobertura de volumes ainda precisam ser projetadas e testadas |
| [Trivy](https://trivy.dev/) | Identificar vulnerabilidades, Secrets e configurações inseguras em código, imagens e clusters | Um resultado sem achados não comprova proveniência, configuração segura em runtime ou ausência de risco |
| [Kubescape](https://kubescape.io/docs/) | Avaliar postura, configurações e controles de segurança de workloads e clusters | Regras precisam ser contextualizadas; exceções e falsos positivos exigem governança |
| [kube-bench](https://aquasecurity.github.io/kube-bench/) | Executar verificações baseadas no CIS Kubernetes Benchmark | Nem todo controle se aplica da mesma forma a distribuições como K3s; revise a correspondência antes de corrigir |
| [Falco](https://falco.org/docs/) | Detectar comportamento suspeito em runtime a partir de eventos do kernel e outras fontes | Requer implantação, ajuste de regras, destino de alertas e capacidade para responder aos eventos |

Ferramentas de varredura geram evidências auxiliares. Elas não substituem patching, privilégio mínimo, isolamento, revisão humana, monitoramento ou testes de recuperação.

## Catálogos e listas `awesome-*`

| Catálogo | Escopo | Observação |
| --- | --- | --- |
| [CNCF Cloud Native Landscape](https://landscape.cncf.io/) | Projetos e produtos cloud native organizados por categoria | Fonte mantida pela CNCF para descoberta; inclusão no mapa não equivale a recomendação ou maturidade CNCF |
| [Awesome Selfhosted](https://github.com/awesome-selfhosted/awesome-selfhosted) | Serviços e aplicações livres que podem ser hospedados pelo próprio usuário | Útil para descoberta; valide imagem, dependências, autenticação, backup e manutenção de cada projeto |
| [Awesome Docker](https://github.com/veggiemonk/awesome-docker) | Ferramentas, imagens, operação e recursos relacionados ao Docker | Lista comunitária; observe os marcadores de projetos comerciais ou sem atividade |
| [Awesome Compose](https://github.com/docker/awesome-compose) | Exemplos de Docker Compose mantidos pela organização Docker | Os próprios mantenedores classificam os exemplos como ponto de partida, não configuração pronta para produção |
| [Awesome Kubernetes](https://github.com/ramitsurana/awesome-kubernetes) | Projetos, materiais e ferramentas para Kubernetes | Catálogo amplo; confirme atividade e compatibilidade diretamente no projeto escolhido |
| [Awesome K8s Tools](https://github.com/vilaca/awesome-k8s-tools) | Índice automatizado de ferramentas para containers e Kubernetes | Ajuda a comparar categorias e atividade, mas métricas de repositório não substituem avaliação técnica |
| [Awesome Security](https://github.com/sbilly/awesome-security) | Segurança de rede, host, aplicações e DevSecOps, incluindo firewalls | Mistura ferramentas defensivas e ofensivas; defina autorização e ambiente isolado antes de testar qualquer item |
| [Awesome Sysadmin](https://github.com/awesome-foss/awesome-sysadmin) | Software livre para administração de sistemas e serviços | Útil para hosts, inventário e automação; verifique manutenção e privilégio exigido por cada ferramenta |
| [Awesome WAF](https://github.com/0xInfection/Awesome-WAF) | Pesquisa e ferramentas sobre Web Application Firewalls | WAF atua sobre tráfego de aplicação e não substitui UFW, firewalld, nftables ou o firewall dos nós K3s |
| [Awesome](https://github.com/sindresorhus/awesome) | Índice de listas comunitárias de muitos assuntos | Use como ponto de descoberta e siga até a documentação e o repositório oficial de cada projeto |

Antes de copiar um exemplo de um catálogo, confira a data da última release, mantenedores ativos, advisories de segurança, licença, imagens oficiais, checksums ou assinaturas, privilégios solicitados e procedimento de remoção. Faça a primeira implantação em ambiente isolado e registre por que a ferramenta foi escolhida.

## Fontes e leitura adicional

- [Organização de acesso com kubeconfig — Kubernetes](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/): explica contextos, usuários e clusters consumidos por clientes como Lens, Headlamp e K9s.
- [Boas práticas de RBAC — Kubernetes](https://kubernetes.io/docs/concepts/security/rbac-good-practices/): orienta a limitar credenciais e permissões concedidas a interfaces e automações.
- [Proteção do daemon Docker](https://docs.docker.com/engine/security/protect-access/): documenta o risco e as formas de proteger acesso remoto ao Engine.
- [Swarm mode — Docker Docs](https://docs.docker.com/engine/swarm/): referência oficial da orquestração, dos managers, workers, serviços e estado desejado no Docker Swarm.
- [Cloud Native Landscape Guide — CNCF](https://landscapeapp.cncf.io/cncf/guide): explica as categorias e como interpretar o landscape sem confundir presença com endosso.
- [OpenSSF Scorecard](https://scorecard.dev/): apresenta verificações que podem auxiliar a avaliar práticas de segurança de projetos open source, sem substituir uma análise própria.
