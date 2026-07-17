---
title: Runbook de manutenção e mudanças
sidebar:
  order: 3
---

Use este runbook para registrar uma rotina recorrente ou conduzir uma mudança planejada no cluster e nos workloads. Ele organiza decisões, responsáveis, horários e evidências; os critérios técnicos continuam nos guias temáticos:

- [guia de operação contínua](../guides/operations-overview/);
- [prontidão de workloads para produção](../kubernetes/workloads/production-readiness/);
- [ciclo de vida de imagens e rollouts](../guides/deployment/image-lifecycle/);
- [observabilidade e alertas](observability-and-alerting/);
- [backup e recuperação](backup-and-recovery/);
- [manutenção do cluster K3s](k3s-cluster-maintenance/);
- [validação pós-instalação](k3s-post-install-checklist/).

Crie um registro novo para cada execução. Não sobrescreva a execução anterior: o histórico permite comparar duração, falhas, capacidade e eficácia do rollback ao longo do tempo.

## Regras de registro

- use timestamps no formato ISO 8601 com fuso, por exemplo `2026-07-16T21:30:00-03:00`;
- atribua uma pessoa responsável por coordenar a execução e outra, quando possível, para revisar decisões de parada ou rollback;
- registre como `N/A` apenas o que realmente não se aplica e inclua a justificativa;
- prefira links para artefatos versionados, dashboards e registros imutáveis em vez de copiar grandes saídas;
- não anexe tokens, kubeconfigs, conteúdo de Secrets, chaves privadas, cookies, URLs assinadas ou variáveis sensíveis;
- remova dados pessoais e identificadores do ambiente que não sejam necessários para comprovar o resultado;
- registre desvios e decisões durante a execução, enquanto o contexto ainda está disponível.

## Rotinas recorrentes

As rotinas abaixo são um índice. Selecione os itens aplicáveis no [guia de operação contínua](../guides/operations-overview/) e registre somente resultado, exceções, evidências e ações pendentes neste runbook; não replique todos os checkboxes a cada execução.

| Frequência inicial | Foco da revisão | Guias para critérios e validação |
| --- | --- | --- |
| Contínua ou diária | Saúde do cluster e dos workloads, sinais externos, capacidade, coleta de telemetria, alertas e último backup esperado | [Observabilidade e alertas](observability-and-alerting/), [backup e recuperação](backup-and-recovery/) e [guia contínuo](../guides/operations-overview/) |
| Semanal | Tendências, alertas ruidosos ou recorrentes, certificados, divergência de imagens e presença dos backups externos | [Observabilidade e alertas](observability-and-alerting/), [ciclo de vida de imagens](../guides/deployment/image-lifecycle/) e [backup e recuperação](backup-and-recovery/) |
| Mensal ou por janela | Atualizações disponíveis, compatibilidade, capacidade, requests e limits, retenção, responsáveis e prontidão para drenar nós | [Prontidão de workloads](../kubernetes/workloads/production-readiness/), [ciclo de vida de imagens](../guides/deployment/image-lifecycle/) e [manutenção do K3s](k3s-cluster-maintenance/) |
| Trimestral ou conforme a criticidade | Restauração cronometrada, teste ponta a ponta de alertas, perda de componentes, acessos e dependências fora de suporte | [Backup e recuperação](backup-and-recovery/), [observabilidade e alertas](observability-and-alerting/) e [guia contínuo](../guides/operations-overview/) |

Uma rotina sem mudança pode encerrar depois da revisão e do registro de ações pendentes. Quando houver atualização, reinicialização, drenagem, alteração de configuração ou recuperação, preencha também todas as seções de mudança a seguir.

## Preparação da mudança

### Identificação, escopo e autoridade

Registre:

- identificador do ticket ou da mudança;
- tipo de execução: rotina, implantação, atualização, manutenção de host, recuperação ou teste;
- ambiente, cluster, namespaces, nós, componentes e workloads dentro do escopo;
- itens explicitamente fora do escopo;
- owner técnico, executor, revisor e autoridade que pode ordenar parada ou rollback;
- criticidade, impacto máximo tolerável, RTO e RPO aplicáveis;
- estado desejado, commit, tag, digest, chart ou versão de configuração que será aplicado.

Escopo impreciso dificulta avaliar o impacto e pode levar o rollback a reverter mudanças não relacionadas. Quando várias mudanças independentes forem necessárias, prefira registros e critérios separados.

### Dependências e comunicação

Liste dependências internas e externas, como API Kubernetes, etcd, DNS, identidade, registro de imagens, armazenamento, banco de dados, filas, provedores externos, GitOps e monitoramento. Para cada dependência crítica, registre owner, condição esperada e como a indisponibilidade será detectada.

Defina também:

- público afetado e canais de aviso;
- mensagem e horário previstos para início, atualização de estado, conclusão e rollback;
- contatos de escalonamento e especialistas de sobreaviso;
- incidentes ou mudanças simultâneas capazes de interferir na leitura dos sinais;
- silêncios de alertas estritamente necessários, todos com owner, motivo e expiração.

### Janela e papéis

A janela deve reservar tempo para execução, observação e rollback. Não use todo o período disponível apenas para aplicar a mudança.

| Marco | Data e hora planejadas | Data e hora reais | Responsável |
| --- | --- | --- | --- |
| Início da preparação | | | |
| Início da mudança | | | |
| Limite para decidir rollback | | | |
| Fim da execução | | | |
| Fim da observação | | | |
| Comunicação de encerramento | | | |

### Pré-condições e baseline

Antes de alterar o ambiente, registre uma baseline comparável com a validação posterior. Inclua apenas sinais relevantes ao risco da mudança.

| Sinal ou teste | Fonte | Valor esperado | Valor observado | Timestamp | Evidência | Estado |
| --- | --- | --- | --- | --- | --- | --- |
| Nós e control plane | | | | | | |
| Workloads e réplicas | | | | | | |
| Taxa de erro e latência | | | | | | |
| CPU, memória e armazenamento | | | | | | |
| Fluxo funcional crítico | | | | | | |
| Coleta e entrega de alertas | | | | | | |

Confirme ainda que:

- acessos administrativos e acesso de emergência foram testados sem compartilhar credenciais;
- o estado desejado e a versão anterior estão identificáveis e disponíveis fora do cluster;
- não há incidente ativo ou degradação sem explicação que invalide a baseline;
- responsáveis, revisores e contatos necessários estão disponíveis;
- o relógio dos sistemas usados para evidência está sincronizado;
- a [validação pós-instalação](k3s-post-install-checklist/) e a [prontidão dos workloads](../kubernetes/workloads/production-readiness/) não possuem pendências bloqueantes aplicáveis.

### Backup e prontidão de restauração

Ter um arquivo de backup não prova que o ambiente pode ser recuperado. Use o [guia de backup e recuperação](backup-and-recovery/) para distinguir snapshot do datastore, volumes, backups próprios das aplicações, configurações, credenciais e token do K3s.

| Ativo | RPO/RTO | Método e destino | Último sucesso | Cópia fora do domínio de falha | Último restore testado | Evidência | Estado |
| --- | --- | --- | --- | --- | --- | --- | --- |
| etcd/datastore e token K3s | | | | | | | |
| Volumes persistentes | | | | | | | |
| Banco ou aplicação stateful | | | | | | | |
| Estado desejado e configurações | | | | | | | |
| Credenciais necessárias à recuperação | | | | | | | |

Registre quem pode iniciar uma restauração, onde está o procedimento acessível durante uma indisponibilidade e quanto tempo real o último teste consumiu. Se o restore nunca foi testado ou não cabe na janela e no RTO, trate isso como risco explícito e obtenha a decisão da autoridade responsável antes de avançar.

### Matriz de compatibilidade

Não presuma compatibilidade apenas porque cada componente possui uma versão mais nova. Consulte as notas de versão, políticas de version skew e matrizes oficiais.

| Componente | Versão atual | Versão alvo | Dependências afetadas | Fonte da compatibilidade | Decisão e restrições |
| --- | --- | --- | --- | --- | --- |
| K3s/Kubernetes | | | | | |
| CRDs e controllers | | | | | |
| Charts e imagens | | | | | |
| CSI/armazenamento | | | | | |
| Gateway, DNS e certificados | | | | | |
| Workload e banco de dados | | | | | |

Registre separadamente versões de charts, aplicações, imagens, CRDs e controllers. Siga o [ciclo de vida de imagens e rollouts](../guides/deployment/image-lifecycle/) para identificar tag, digest, origem, homologação e artefato anterior.

### Capacidade, disrupções e quorum

Antes de drenar, reiniciar ou remover um nó, confirme que o estado remanescente sustenta a carga e o control plane:

| Verificação | Condição mínima para avançar | Resultado | Evidência |
| --- | --- | --- | --- |
| Quorum do datastore/control plane | Quantidade saudável após a indisponibilidade planejada permanece suficiente | | |
| Capacidade de CPU e memória | Workloads cabem nos nós restantes considerando requests e margem operacional | | |
| Volumes e réplicas de dados | Réplicas saudáveis e anexação/movimentação compatível com a mudança | | |
| PodDisruptionBudgets | Evictions permitidas sem violar a disponibilidade acordada | | |
| Distribuição e afinidade | Réplicas podem ser reagendadas nos domínios restantes | | |
| DaemonSets, Jobs e armazenamento local | Exceções e perda temporária ou definitiva estão compreendidas | | |

Um PDB limita determinadas disrupções voluntárias, mas não cria réplicas, capacidade nem proteção contra falhas involuntárias. Se uma drenagem bloquear, investigue a causa; não remova a proteção automaticamente sem uma decisão de risco registrada.

## Plano de execução e controle

### Etapas

Cada etapa deve produzir um resultado observável antes da próxima. Use passos pequenos o suficiente para permitir parada e diagnóstico.

| # | Ação e resultado esperado | Responsável | Início previsto | Duração máxima | Evidência exigida | Estado |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | | | | | | Pendente |
| 2 | | | | | | Pendente |
| 3 | | | | | | Pendente |

Para mudanças em vários nós, registre a ordem e valide a saúde entre eles. Para rollout de workloads, indique o lote, a duração de observação e o sinal que autoriza ampliar a mudança.

### Critérios objetivos

Defina valores mensuráveis antes do início. Evite critérios como “parece saudável” ou “sem muitos erros”.

| Decisão | Critério, limiar e duração | Fonte do sinal | Autoridade |
| --- | --- | --- | --- |
| Avançar | | | |
| Pausar e investigar | | | |
| Interromper sem reverter | | | |
| Iniciar rollback | | | |
| Declarar rollback bem-sucedido | | | |

Exemplos de critérios objetivos incluem número esperado de réplicas disponíveis, tempo máximo de um nó em `NotReady`, taxa de erro abaixo de um limiar por determinado período, latência dentro da baseline, ausência de perda de quorum e conclusão de um fluxo funcional crítico.

### Plano de rollback

O rollback deve ser executável, não apenas uma intenção. Registre:

- estado, versão, manifesto, imagem ou snapshot de destino;
- gatilho objetivo e último horário seguro para iniciar a reversão;
- passos e ordem, incluindo reversão de esquema ou migração de dados quando aplicável;
- responsável por ordenar e executar;
- tempo estimado e sua compatibilidade com a janela e o RTO;
- validações que comprovam a recuperação;
- condições que tornam o rollback inseguro e qual plano de recuperação substitui a reversão.

### Log de timestamps e decisões

Preencha durante a execução, inclusive quando tudo ocorrer como esperado.

| Timestamp | Etapa/evento | Observação ou valor | Decisão | Responsável | Evidência |
| --- | --- | --- | --- | --- | --- |
| | Início da mudança | | | | |
| | | | | | |
| | Fim da aplicação | | | | |
| | Início da observação | | | | |

## Validação e encerramento

### Validação pós-mudança

Repita os sinais da baseline e compare antes e depois. Valide também o estado desejado, as funcionalidades críticas e os riscos específicos da mudança.

| Sinal ou teste | Baseline | Resultado posterior | Diferença aceita? | Timestamp | Evidência |
| --- | --- | --- | --- | --- | --- |
| Versão e configuração observadas | | | | | |
| Nós, control plane e quorum | | | | | |
| Workloads, réplicas e probes | | | | | |
| Erros, latência e saturação | | | | | |
| Armazenamento e dados | | | | | |
| Fluxo funcional crítico | | | | | |
| Métricas, logs e alertas | | | | | |

Consulte os critérios detalhados de [prontidão de workloads](../kubernetes/workloads/production-readiness/), [observabilidade e alertas](observability-and-alerting/) e [manutenção do K3s](k3s-cluster-maintenance/).

### Janela de observação

Registre início, término, owner e carga esperada durante a observação. A janela deve ser suficiente para alcançar os fluxos e tarefas relevantes, como picos de tráfego, Jobs agendados, renovação de leader, anexação de volumes ou reconciliação de controllers.

Não encerre apenas porque o deploy terminou. Confirme que:

- os critérios de sucesso permaneceram atendidos durante toda a janela;
- não surgiu degradação progressiva de latência, erros, capacidade ou filas;
- alertas e silêncios foram revisados, e silêncios temporários expiraram ou foram removidos;
- o rollback permaneceu possível até o ponto previamente definido;
- usuários afetados e owners das dependências receberam a atualização prevista.

### Fechamento e ações pendentes

Registre o resultado como `Sucesso`, `Sucesso com ressalvas`, `Rollback concluído`, `Falha recuperada` ou `Falha pendente`. Inclua duração real, indisponibilidade observada, perda de dados observada, desvios, incidentes relacionados e comparação com os objetivos definidos.

| Ação pendente | Origem/risco | Prioridade | Responsável | Prazo | Ticket | Estado |
| --- | --- | --- | --- | --- | --- | --- |
| | | | | | | |

Encerre somente depois de indexar as evidências, comunicar o resultado e transformar cada pendência em uma ação com owner e prazo. Atualize o runbook quando uma etapa, estimativa ou critério tiver se mostrado incorreto.

## Evidências seguras

Exemplos adequados, depois de revisar e remover dados sensíveis:

- link para commit, pull request, release, digest ou diff do estado desejado;
- saída sanitizada de status de nós, rollout, PDB, snapshot ou versão;
- gráfico ou dashboard com fonte, intervalo, timezone e valores legíveis;
- identificador, timestamp, checksum e estado de um backup, sem credenciais ou URL assinada;
- resultado de teste funcional com entrada não sensível e resposta esperada;
- link para ticket, incidente, decisão ou comunicação com controle de acesso apropriado;
- duração medida de restore, drain, rollout, rollback e janela de observação.

Não use como evidência: conteúdo de `Secret`, kubeconfig, token do K3s, chave privada, bearer token, cookie, dump de ambiente, cabeçalho de autenticação, URL pré-assinada ou captura que exponha esses valores. Quando a evidência original for sensível, registre somente o identificador, o owner, o local protegido e a confirmação de revisão.

## Template Markdown copiável

Copie o bloco para uma issue, ticket ou repositório de runbooks. Remova somente as seções comprovadamente não aplicáveis e registre a justificativa.

````markdown
# Execução: <título>

## Identificação

- ID/ticket:
- Tipo: rotina diária | semanal | mensal | trimestral | mudança | recuperação | teste
- Ambiente/cluster:
- Escopo:
- Fora do escopo:
- Owner técnico:
- Executor(es):
- Revisor/autoridade de rollback:
- Criticidade:
- Impacto máximo tolerável:
- RTO/RPO:
- Estado desejado/commit/versão:

## Dependências e comunicação

| Dependência | Owner | Condição esperada | Como detectar falha |
| --- | --- | --- | --- |
| | | | |

- Público afetado:
- Canal de comunicação:
- Contatos e escalonamento:
- Incidentes/mudanças simultâneas:
- Silêncios de alerta, motivo e expiração:

## Janela

| Marco | Planejado | Real | Responsável |
| --- | --- | --- | --- |
| Preparação | | | |
| Início | | | |
| Limite para rollback | | | |
| Fim da execução | | | |
| Fim da observação | | | |

## Baseline e pré-condições

| Sinal/teste | Esperado | Observado | Timestamp | Evidência | Estado |
| --- | --- | --- | --- | --- | --- |
| | | | | | |

- [ ] Acessos e comunicação testados.
- [ ] Estado atual e anterior identificados.
- [ ] Ausência de degradação bloqueante confirmada.
- [ ] Responsáveis e autoridade de rollback disponíveis.
- [ ] Justificativas de itens N/A registradas.

## Backup e restore readiness

| Ativo | RPO/RTO | Último backup | Cópia externa | Último restore testado | Evidência | Estado |
| --- | --- | --- | --- | --- | --- | --- |
| | | | | | | |

- Autoridade para restaurar:
- Procedimento acessível em:
- Risco aceito, se houver:

## Compatibilidade

| Componente | Atual | Alvo | Dependências | Fonte oficial/matriz | Decisão |
| --- | --- | --- | --- | --- | --- |
| | | | | | |

## Capacidade, PDB e quorum

| Verificação | Mínimo para avançar | Resultado | Evidência |
| --- | --- | --- | --- |
| Quorum | | | |
| CPU e memória remanescentes | | | |
| Volumes/réplicas | | | |
| PDB e evictions permitidas | | | |
| Distribuição/reagendamento | | | |

## Plano passo a passo

| # | Ação/resultado esperado | Responsável | Início | Tempo máximo | Evidência | Estado |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | | | | | | Pendente |

## Critérios de decisão

| Decisão | Critério, limiar e duração | Fonte | Autoridade |
| --- | --- | --- | --- |
| Avançar | | | |
| Pausar | | | |
| Parar | | | |
| Rollback | | | |
| Rollback concluído | | | |

## Rollback

- Estado/versão de destino:
- Último horário seguro para iniciar:
- Passos e ordem:
- Responsável:
- Duração estimada:
- Validação do rollback:
- Condição que impede rollback e plano alternativo:

## Log da execução

| Timestamp ISO 8601 | Evento/etapa | Observação | Decisão | Responsável | Evidência |
| --- | --- | --- | --- | --- | --- |
| | Início | | | | |

## Validação pós-mudança

| Sinal/teste | Baseline | Resultado | Diferença aceita? | Timestamp | Evidência |
| --- | --- | --- | --- | --- | --- |
| | | | | | |

## Observação

- Início/fim:
- Owner:
- Carga e fluxos esperados:
- Critérios mantidos durante toda a janela:
- Alertas/silêncios revisados:
- Comunicação atualizada:

## Encerramento

- Resultado:
- Duração e indisponibilidade reais:
- Perda de dados observada:
- Desvios/incidentes:
- Índice de evidências sem segredos:
- Comunicação final:

| Ação pendente | Risco | Prioridade | Responsável | Prazo | Ticket | Estado |
| --- | --- | --- | --- | --- | --- | --- |
| | | | | | | |
````

## Fontes e leitura adicional

- [K3s — Manual Upgrades](https://docs.k3s.io/upgrades/manual): documenta a ordem de atualização, as restrições entre versões e a validação progressiva dos nós.
- [K3s — Backup and Restore](https://docs.k3s.io/datastore/backup-restore): descreve snapshots, restauração do datastore e a necessidade de preservar o token do servidor.
- [K3s — Rolling Back K3s](https://docs.k3s.io/upgrades/roll-back): apresenta os pré-requisitos e o processo oficial de rollback do K3s.
- [Kubernetes — Safely Drain a Node](https://kubernetes.io/docs/tasks/administer-cluster/safely-drain-node/): explica cordon, drain, eviction e os cuidados ao retirar um nó para manutenção.
- [Kubernetes — Disruptions](https://kubernetes.io/docs/concepts/workloads/pods/disruptions/): define disrupções voluntárias e involuntárias, PodDisruptionBudget e seus limites.
- [Kubernetes — Version Skew Policy](https://kubernetes.io/releases/version-skew-policy/): registra as combinações suportadas entre componentes e clientes Kubernetes.
- [Kubernetes — Operating Clusters](https://kubernetes.io/docs/tasks/administer-cluster/): reúne procedimentos oficiais de administração, manutenção, segurança e recuperação de clusters.
