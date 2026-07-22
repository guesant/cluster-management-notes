---
title: "Trilha CNCF/Linux Foundation: Kubernetes e o ecossistema cloud native"
description: KCNA e KCSA como certificações conceituais de múltipla escolha, CKA/CKAD/CKS como certificações práticas performance-based, e as especializações por projeto (Prometheus, OpenTelemetry, Argo, Istio, Cilium, Kyverno, GitOps, Backstage, platform engineering), com domínios auditados contra as páginas oficiais.
sidebar:
  order: 2
---

> **Para quem é:** quem já decidiu, pelo [mapa de certificações](../), que a trilha CNCF/Linux Foundation é o próximo passo, e quer saber o que cada prova cobre antes de escolher por onde começar.

Todas as afirmações de domínio e percentual desta página foram auditadas contra as páginas oficiais da CNCF (`cncf.io/certification/` ou `cncf.io/training/certification/`) em 2026-07-22; confira a fonte de cada certificação antes de estudar, porque blueprints de exame mudam com o tempo. Pegadinhas e bizus são recomendação editorial deste notebook, baseada em padrões recorrentes de erro decorrentes do formato e dos objetivos oficiais de cada prova, claramente separados do fato oficial.

## KCNA e KCSA: as duas certificações conceituais

**KCNA** (Kubernetes and Cloud Native Associate) é uma prova de múltipla escolha, pré-profissional, cobrindo fundamentos de Kubernetes (44%), orquestração de containers (28%), entrega de aplicação cloud native (16%) e arquitetura cloud native (12%). **KCSA** (Kubernetes and Cloud Native Security Associate), também múltipla escolha, cobre segurança de componentes do cluster (22%), fundamentos de segurança do Kubernetes (22%), modelo de ameaça (16%), segurança de plataforma (16%), visão geral de segurança cloud native (14%) e frameworks de compliance (10%).

> **Recomendação editorial do notebook (não fato oficial):** as pegadinhas mais comuns do KCNA giram em torno de distinguir container de Pod de Deployment, entender que um Service não executa nem escala Pods sozinho, e diferenciar Ingress, controlador de Ingress e Gateway API. Estudar por responsabilidade ("quem cria? quem observa? quem reconcilia? onde roda?") rende mais do que decorar a lista de projetos CNCF. Para o KCSA, a matriz risco → controle (RBAC para quem pode fazer o quê, NetworkPolicy para isolamento de rede, Pod Security Standards/SecurityContext para postura de Pod, scanner/assinatura/admissão para supply chain, criptografia em repouso, audit logs para rastreamento) organiza melhor o estudo do que memorizar definições soltas; a pegadinha mais comum é confundir autenticação com autorização, e assumir que RBAC bloqueia tráfego de rede (não bloqueia; isso é papel de NetworkPolicy, que por sua vez depende do CNI implementá-la).

## CKA, CKAD e CKS: as três certificações práticas

As três são performance-based (resolução de tarefas reais contra um cluster ao vivo, 2 horas), não múltipla escolha, o que muda fundamentalmente como estudar para elas (ver a distinção de formato já discutida no [mapa de certificações](../)).

| Certificação | Domínios e peso |
| --- | --- |
| **CKA** (Administrator) | Troubleshooting 30%, Arquitetura/instalação 25%, Serviços e redes 20%, Workloads/scheduling 15%, Storage 10% |
| **CKAD** (Application Developer) | Ambiente/configuração/segurança 25%, Design de aplicação 20%, Deployment 20%, Redes 20%, Observabilidade/manutenção 15% |
| **CKS** (Security Specialist) | Vulnerabilidades de microsserviço 20%, Segurança de supply chain 20%, Monitoramento/logging/runtime 20%, Cluster hardening 15%, System hardening 15%, Cluster setup 10% |

CKS exige ter passado no CKA antes de tentar a prova; até a escrita, a própria CNCF esclarece que o CKA **não precisa continuar ativo** (não expirado) para satisfazer esse pré-requisito, só ter sido aprovado uma vez. Isso corrige uma suposição comum (e uma imprecisão que já esteve registrada nas notas internas deste projeto) de que seria necessário manter o CKA em dia para prestar o CKS.

> **Recomendação editorial do notebook (não fato oficial):** para o CKA, o erro mais caro não é não saber o comando, é resolver a tarefa no contexto/namespace errado, com nome, label ou porta divergente do enunciado, ou deixar um Pod controlado por um Deployment editado diretamente (o controller reverte a mudança); gerar YAML imperativo com `--dry-run=client -o yaml`, conferir o contexto antes de cada questão, e seguir a ordem `get → describe → logs → events` para diagnosticar reduz esse tipo de erro mais do que decorar sintaxe isolada. Para o CKAD, as pegadinhas mais comuns envolvem confundir initContainer com sidecar, uma liveness probe que depende de uma dependência externa (derruba o Pod à toa), e esquecer que um ConfigMap montado como volume não reinicia o processo sozinho para pegar a mudança. Para o CKS, aplicar uma política sem verificar se o modo de enforcement está ativo (`enforce`/`audit`/`warn` do Pod Security Admission) é o erro mais recorrente; tentar violar deliberadamente cada controle depois de aplicá-lo é a forma mais confiável de confirmar que ele realmente bloqueia, não só que existe no manifest.

## Especializações por projeto

Cada uma cobre um projeto específico do ecossistema CNCF, com correspondência direta a tecnologias que este notebook já usa ou compara.

**PCA** (Prometheus Certified Associate): PromQL é o domínio de maior peso (28%), seguido de fundamentos do Prometheus (20%). A pegadinha mais comum é confundir `counter` com `gauge`, ou aplicar `histogram_quantile` sem agregar os buckets antes.

**OTCA** (OpenTelemetry Certified Associate): API e SDK concentram quase metade da prova (46%), seguido do Collector (26%). A distinção mais recorrente é API (a interface que o código da aplicação usa) vs. SDK (a implementação concreta por trás dela), e receiver/processor/exporter/connector como as quatro peças do pipeline do Collector.

**CAPA** (Certified Argo Project Associate): cobre os quatro projetos Argo, com Argo Workflows (36%) e Argo CD (34%) somando 70% da prova; Argo Rollouts (18%) e Argo Events (12%) completam o restante. Tem correspondência direta com a arquitetura GitOps deste notebook (Argo CD). A pegadinha mais citada é confundir `Healthy` com `Synced` no Argo CD: um recurso pode estar sincronizado com o Git e ainda assim não saudável, e vice-versa.

**ICA** (Istio Certified Associate): Traffic Management é o domínio de maior peso (40%), à frente de resiliência/fault injection e segurança de workloads (20% cada). A distinção central é `VirtualService` (para onde o tráfego vai) vs. `DestinationRule` (como ele chega lá, incluindo política de balanceamento e subsets).

**CCA** (Cilium Certified Associate): Arquitetura é o domínio de maior peso (20%), seguido de Network Policy (18%) e Service Mesh (16%), num total de oito domínios. A pegadinha mais citada é tratar `CiliumNetworkPolicy` como um simples superconjunto de `NetworkPolicy` do Kubernetes nativo, sem entender que Cilium decide por identidade, não só por IP.

**KCA** (Kyverno Certified Associate): Writing Policies é o domínio de maior peso (32%), à frente de fundamentos e instalação (18% cada). A distinção mais recorrente é `generate` (cria um novo recurso a partir de um evento) vs. `mutateExisting` (altera um recurso já existente), e `ClusterPolicy` vs. `Policy` com escopo de namespace.

**CGOA** (Certified GitOps Associate): Princípios GitOps é o domínio de maior peso (30%), à frente de terminologia e padrões (20% cada). A pegadinha mais citada é tratar qualquer pipeline acionado por push a um repositório Git como "GitOps": o modelo GitOps propriamente dito depende de reconciliação contínua puxando o estado declarado, não de um gatilho único de CI.

**CBA** (Certified Backstage Associate): Customização é o domínio de maior peso (32%), cobrindo criação e modificação de plugins e o framework de frontend do Backstage. A distinção mais recorrente é entre o catálogo do Backstage (registro de entidades: Component, System, Domain, Resource, API) e service discovery em tempo de execução, que o catálogo não substitui.

**CNPA / CNPE** (Platform Engineering Associate / Engineer): CNPA é conceitual (múltipla escolha); CNPE é performance-based (120 minutos), construído sobre o CNPA, cobrindo GitOps/entrega contínua e APIs de plataforma/self-service (25% cada), observabilidade/operações (20%), arquitetura de plataforma (15%) e segurança/enforcement de política (15%). A pegadinha mais citada é tratar uma equipe central respondendo tickets como se fosse "uma plataforma": o critério que a certificação cobra é a plataforma como produto interno, com golden path e portal de self-service, não um time de atendimento reativo.

## Páginas relacionadas

- [Mapa de certificações](../): a distinção entre certificação, badge e Applied Skill, e entre prova de múltipla escolha e performance-based.

## Referências

- [CNCF: KCNA](https://www.cncf.io/certification/kcna/) e [KCSA](https://www.cncf.io/certification/kcsa/): domínios e formato (até a escrita, 2026-07-22).
- [CNCF: CKA](https://www.cncf.io/certification/cka/), [CKAD](https://www.cncf.io/certification/ckad/) e [CKS](https://www.cncf.io/certification/cks/): domínios, formato e pré-requisitos (até a escrita, 2026-07-22).
- [CNCF: PCA](https://www.cncf.io/certification/pca/), [OTCA](https://www.cncf.io/training/certification/otca/), [CAPA](https://www.cncf.io/training/certification/capa/), [ICA](https://www.cncf.io/training/certification/ica/), [CCA](https://www.cncf.io/training/certification/cca/), [KCA](https://www.cncf.io/training/certification/kca/), [CGOA](https://www.cncf.io/training/certification/cgoa/), [CBA](https://www.cncf.io/training/certification/cba/), [CNPA](https://www.cncf.io/training/certification/cnpa/) e [CNPE](https://www.cncf.io/training/certification/cnpe/): domínios de cada especialização (até a escrita, 2026-07-22; confira a página oficial de cada uma para o blueprint vigente).
