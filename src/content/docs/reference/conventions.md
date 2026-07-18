---
title: Escopo, convenções e versões
sidebar:
  order: 1
---

## Escopo e premissas

- Hosts Debian ou Ubuntu com `systemd`.
- Arquiteturas `amd64` e `arm64`.
- Comandos de administração do host executados como `root`. Quando estiver em uma conta comum, abra antes um shell com `sudo -i`.
- Nomes de nós, endereços IP, nomes DNS, portas e demais parâmetros do ambiente são solicitados pelos blocos interativos antes da execução.
- O kubeconfig administrativo do K3s concede acesso total ao cluster e deve ser armazenado com permissão `0600`.
- As versões abaixo são os valores padrão oferecidos pelos prompts para facilitar o copia e cola. Elas são referências, não uma matriz de compatibilidade homologada por este repositório; informe outra versão quando necessário e valide o conjunto em homologação antes de atualizar produção.

:::note
Nos prompts, o valor entre colchetes é usado quando Enter é pressionado sem digitar nada. Os blocos interativos encapsulados usam `bash <<'EOF'`. Não acrescente `-c`: essa opção exige o script como argumento, enquanto o heredoc entrega o script pela entrada padrão. Dentro desses blocos, os prompts leem de `/dev/tty` para não consumir as próximas linhas do próprio heredoc.
:::

## Versões de referência

Última revisão documental desta tabela: **2026-07-16**.

| Componente | Versão padrão usada ou sugerida | Fonte para releases e compatibilidade |
| --- | --- | --- |
| K3s | `v1.36.1+k3s1` | [Releases do K3s](https://github.com/k3s-io/k3s/releases) |
| Gateway API, canal Standard | `v1.5.1` | [Releases da Gateway API](https://github.com/kubernetes-sigs/gateway-api/releases) |
| cert-manager | `v1.21.0` | [Releases suportadas](https://cert-manager.io/docs/releases/) |
| cmctl | `v2.5.0` | [Releases do cmctl](https://github.com/cert-manager/cmctl/releases) |
| Longhorn e longhornctl | `1.12.0` | [Documentação versionada do Longhorn](https://longhorn.io/docs/1.12.0/) |
| Chart Helm do Argo CD | `10.1.3` | [Chart `argo-cd` no Artifact Hub](https://artifacthub.io/packages/helm/argo/argo-cd) |
| Chart CloudNativePG / operator | `0.29.0` / `1.30.0` | [Releases do operator](https://github.com/cloudnative-pg/cloudnative-pg/releases) e [do chart](https://github.com/cloudnative-pg/charts/releases) |
| Chart Infisical Secrets Operator | `0.11.3` | [Repositório oficial do operator](https://github.com/Infisical/infisical-secrets-operator) |

Esses valores não descrevem automaticamente a versão mais recente upstream, a versão instalada em um cluster nem uma combinação homologada. Antes de atualizar, registre separadamente: versão atualmente observada, versão proposta, fonte upstream, data da avaliação, compatibilidade, resultado de homologação e decisão de rollout ou adiamento. O `cmctl` possui ciclo de releases independente do cert-manager e não deve ser pareado pelo mesmo número de versão.

## Convenções de execução

Cada bloco shell informa onde deve ser executado:

- **nó alvo:** host Linux que será alterado; pode ser manager, agent ou uma máquina fora do cluster;
- **nó manager:** nó K3s com função server/control-plane;
- **nó agent:** nó K3s com função agent/worker;
- **máquina com KUBECONFIG:** qualquer manager ou estação administrativa que tenha `kubectl`, acesso à API e um kubeconfig com as permissões necessárias;
- **estação administrativa:** máquina de origem usada para SSH, túneis ou instalação de CLIs; não precisa pertencer ao cluster.

## Convenções de fontes

Cada página temática deve terminar com `## Fontes e leitura adicional`. Ao criar ou revisar conteúdo:

- priorize documentação, especificações, manuais, repositórios e notas de release mantidos pelo próprio projeto;
- use a documentação da mesma linha de versão descrita na página quando ela for versionada;
- mantenha links contextuais junto de afirmações sensíveis a versão, compatibilidade ou segurança, além da lista final;
- descreva em uma frase o que cada link embasa ou aprofunda;
- identifique claramente fontes comunitárias, comparações e listas de descoberta, sem tratá-las como documentação normativa;
- confirme no upstream comandos, defaults e suporte antes de atualizar o texto;
- registre uma data de revisão quando a página mantiver uma tabela de versões ou outra informação que envelheça rapidamente.

Listas como `awesome-*`, métricas de popularidade e catálogos de produtos ajudam a encontrar opções, mas não comprovam segurança, manutenção, compatibilidade ou adequação. Para escolhê-las, siga os critérios do [índice de ferramentas e catálogos](../tools-and-resources/) e retorne à fonte oficial de cada projeto.

## Fontes e leitura adicional

- [Política de version skew — Kubernetes](https://kubernetes.io/releases/version-skew-policy/): define as combinações suportadas entre componentes e clientes Kubernetes.
- [Atualizações manuais — K3s](https://docs.k3s.io/upgrades/manual): documenta canais, versões explícitas e ordem de atualização dos nós K3s.
- [Configuração por arquivo — K3s](https://docs.k3s.io/installation/configuration): explica a precedência e a manutenção de opções em `/etc/rancher/k3s/config.yaml`.
- [Semantic Versioning](https://semver.org/): especificação usada por muitos projetos para comunicar mudanças compatíveis e incompatíveis.
- [Charts e versionamento — Helm](https://helm.sh/docs/topics/charts/#charts-and-versioning): diferencia a versão do chart da versão da aplicação empacotada.
