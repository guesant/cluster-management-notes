---
title: Guia de operação contínua
description: Checklist de boas práticas, monitoramento, alertas, atualizações, probes, manutenção e recuperação para operar clusters K3s.
---

Este guia complementa a [validação pós-instalação](../../operations/k3s-post-install-checklist/). A validação confirma que o cluster e os módulos escolhidos terminaram o bootstrap em condições conhecidas; os checklists abaixo ajudam a manter cluster e workloads observáveis, atualizáveis e recuperáveis ao longo do tempo.

## Como usar este guia

- copie os blocos aplicáveis para uma issue, ticket ou runbook operacional;
- registre responsável, data, resultado e uma evidência para cada execução;
- marque um item como não aplicável somente com a justificativa registrada;
- ajuste a frequência à criticidade do ambiente, ao impacto de indisponibilidade e aos objetivos de recuperação;
- transforme falhas encontradas em ações com responsável e prazo, em vez de apenas desmarcar o item.

As frequências deste guia são pontos de partida. Um ambiente crítico pode exigir verificações e testes mais frequentes.

## 1. Prontidão antes da produção

### Responsabilidade e boas práticas

**Procedimento:** [prontidão de workloads para produção](../../kubernetes/workloads/production-readiness/). **Evidência mínima:** owner e criticidade registrados, manifesto ou revisão versionada e resultado das validações aplicáveis.

- [ ] Há um responsável operacional e um canal de escalonamento definidos para cada cluster e workload crítico.
- [ ] Criticidade, dependências, janela de manutenção e impacto esperado de indisponibilidade estão registrados.
- [ ] O estado desejado está versionado e pode ser consultado sem depender do próprio cluster.
- [ ] Os procedimentos de implantação, atualização, rollback e recuperação estão acessíveis durante uma indisponibilidade.
- [ ] ServiceAccounts, RBAC, credenciais e permissões do container seguem o privilégio mínimo.
- [ ] Requests e limits foram definidos a partir da necessidade do workload e serão revisados usando o consumo observado.
- [ ] Workloads que precisam de disponibilidade possuem réplicas, distribuição e PodDisruptionBudget compatíveis com a topologia e com as manutenções planejadas.
- [ ] Segredos não aparecem em manifests, imagens, argumentos, logs ou evidências do checklist.

### Imagens e política de atualização

**Procedimento:** [ciclo de vida de imagens de containers](../deployment/image-lifecycle/). **Evidência mínima:** tag e digest desejados e observados, origem da mudança, avaliação de compatibilidade, homologação e referência de rollback.

- [ ] Nenhum workload de produção usa `latest`, `lts`, `stable` ou outra tag flutuante como versão efetiva.
- [ ] Cada imagem usa uma versão explícita e, quando a reprodutibilidade exigir, também um digest imutável.
- [ ] Registro, imagem, tag, digest efetivamente implantado e origem da atualização são inventariados.
- [ ] A versão ou revisão de charts, controllers, operators, CRDs e imagens é registrada separadamente; a versão do chart não é tratada como prova da imagem em execução.
- [ ] A política de pull é conhecida e uma atualização altera o estado desejado, em vez de republicar conteúdo diferente sob a mesma tag.
- [ ] Origem, vulnerabilidades conhecidas e, quando exigido pelo ambiente, assinatura ou proveniência das imagens são verificadas.
- [ ] Uma automação de atualização, quando adotada, propõe uma mudança revisável e não troca imagens de produção silenciosamente.
- [ ] Notas da versão, correções de segurança, mudanças incompatíveis e matriz de compatibilidade são revisadas antes da atualização.
- [ ] A nova versão passa por homologação ou rollout progressivo com critérios objetivos de sucesso e interrupção.
- [ ] A configuração e a imagem anteriores continuam identificáveis e existe um procedimento de rollback testado.

### Probes e ciclo de vida

**Procedimento:** [prontidão de workloads para produção](../../kubernetes/workloads/production-readiness/). **Evidência mínima:** semântica de cada probe, tempos medidos e resultados dos testes de inicialização, indisponibilidade, travamento e encerramento.

- [ ] Cada workload de longa duração foi avaliado individualmente quanto à necessidade de `startupProbe`, `readinessProbe` e `livenessProbe`.
- [ ] A readiness só libera tráfego quando a aplicação consegue atender requisições; sua falha retira o Pod do serviço sem provocar reinícios desnecessários.
- [ ] A liveness detecta uma condição da própria aplicação que um reinício pode corrigir e não depende de serviços externos cuja falha causaria reinícios em cascata.
- [ ] Aplicações com inicialização lenta usam startup probe ou limites compatíveis com o tempo real de inicialização.
- [ ] Intervalos, timeouts e limites de falha foram medidos e testados, não apenas copiados de outro workload.
- [ ] Inicialização, indisponibilidade temporária, travamento, recuperação e encerramento gracioso foram observados em teste.
- [ ] O prazo de terminação e o comportamento de shutdown permitem retirar o Pod do tráfego e concluir requisições dentro do limite definido.
- [ ] Jobs e tarefas finitas não receberam probes inadequadas apenas para cumprir o checklist.

### Monitoramento e observabilidade

**Procedimento:** [observabilidade e alertas](../../operations/observability-and-alerting/). **Evidência mínima:** inventário de sinais e targets, dashboards ou consultas, retenção, teste de indisponibilidade e confirmação de monitoramento externo.

- [ ] Existe monitoramento da saúde dos nós, API/control plane, workloads, armazenamento e componentes opcionais adotados.
- [ ] Dashboards apresentam, quando aplicável, disponibilidade, taxa de erros, latência, saturação, capacidade e tendência de crescimento.
- [ ] Reinícios, `CrashLoopBackOff`, `OOMKilled`, Pods pendentes, falhas de probes e indisponibilidade de réplicas são detectáveis.
- [ ] Capacidade de CPU, memória, disco dos hosts e volumes persistentes possui limites operacionais conhecidos.
- [ ] Logs necessários ao diagnóstico são coletados fora do ciclo de vida dos Pods, possuem retenção definida e não expõem segredos.
- [ ] A necessidade de traces foi avaliada para fluxos distribuídos em que métricas e logs não permitem localizar a origem da latência ou do erro.
- [ ] Retenção, persistência e capacidade da própria plataforma de monitoramento estão definidas.
- [ ] O pipeline de coleta e consulta é monitorado e existe uma verificação externa capaz de detectar a indisponibilidade do cluster ou do próprio monitoramento.

### Alertas

**Procedimento:** [observabilidade e alertas](../../operations/observability-and-alerting/). **Evidência mínima:** regra, owner, severidade, runbook, destino e resultado datado de um teste ponta a ponta.

- [ ] Cada alerta representa uma condição acionável e possui severidade, responsável, destino e link para o procedimento de resposta.
- [ ] Limiares e duração reduzem ruído sem esconder falhas reais; eventos informativos que não exigem ação não acordam uma pessoa.
- [ ] Agrupamento, roteamento e silêncios de manutenção estão definidos, e todo silêncio possui expiração.
- [ ] Os receptores reais foram configurados e um teste ponta a ponta confirmou geração, roteamento e recebimento.
- [ ] Existe detecção da ausência ou falha do próprio pipeline de alertas.
- [ ] Há alertas, conforme aplicável, para indisponibilidade da API, perda de quorum, nós `NotReady`, falhas recorrentes de workloads, saturação, capacidade de disco ou volumes, backup ausente ou falho e certificados próximos do vencimento.

### Backups e recuperação

**Procedimento:** [backup e recuperação](../../operations/backup-and-recovery/). **Evidência mínima:** matriz de ativos, RPO/RTO, última execução válida, cópia fora do domínio de falha e resultado cronometrado do último restore drill.

- [ ] Os ativos necessários à recuperação foram inventariados: estado do Kubernetes/etcd, token do K3s, dados dos volumes, backups próprios das aplicações, configurações e credenciais necessárias.
- [ ] Está registrado que snapshot do etcd não inclui dados dos volumes e que réplica de armazenamento não substitui backup.
- [ ] Cada classe de dados possui RPO, perda máxima de dados medida em tempo, definido.
- [ ] Cada serviço possui RTO, tempo máximo para restabelecimento, definido.
- [ ] Frequência e retenção dos backups atendem ao RPO, e o procedimento completo de restauração atende ao RTO.
- [ ] Aplicações stateful possuem backup consistente com sua própria semântica; uma cópia isolada do volume durante escritas não é presumida recuperável.
- [ ] Existe cópia fora do cluster e fora do mesmo domínio de falha dos dados originais.
- [ ] Backups possuem controle de acesso, proteção contra exclusão acidental e criptografia compatíveis com os dados.
- [ ] Falha, atraso ou ausência de uma execução esperada gera um alerta acionável.
- [ ] Uma restauração em ambiente isolado validou a integridade e o funcionamento da aplicação, não apenas a existência dos arquivos.
- [ ] Duração real, perda de dados observada e problemas do teste foram registrados e comparados com RTO e RPO.

## 2. Rotina recorrente

Registre as execuções com o [runbook de manutenção e mudanças](../../operations/maintenance-runbook/). Os itens abaixo definem a cobertura; o runbook guarda responsável, resultado, evidência, exceções e ações pendentes sem duplicar o checklist inteiro.

### Contínua ou diária

- [ ] Nós, control plane, armazenamento e workloads críticos permanecem saudáveis.
- [ ] Endpoints externos e fluxos essenciais estão disponíveis a partir da perspectiva do usuário.
- [ ] Reinícios recorrentes, Pods pendentes, falhas de probes e Jobs com erro são investigados.
- [ ] CPU, memória, disco e volumes permanecem dentro dos limites operacionais definidos.
- [ ] Coleta de métricas, regras de alerta e receptores continuam funcionando.
- [ ] A última execução esperada de cada backup terminou com sucesso e dentro do prazo.
- [ ] O estado GitOps permanece sincronizado e saudável, quando essa estratégia é adotada.

### Semanal

- [ ] Alertas disparados foram revisados quanto a causa, resposta, recorrência e ruído.
- [ ] Tendências de consumo e crescimento de armazenamento foram revisadas.
- [ ] Falhas recorrentes, eventos anormais e degradações de probes possuem acompanhamento.
- [ ] [Certificados](../../kubernetes/extensions/cert-manager/) e credenciais próximos do vencimento foram identificados.
- [ ] Não surgiram workloads com [tags flutuantes, imagens sem inventário ou versões divergentes](../deployment/image-lifecycle/) do estado desejado.
- [ ] [Backups externos esperados](../../operations/backup-and-recovery/) estão presentes dentro da retenção definida.

### Mensal ou por janela de manutenção

- [ ] Novas versões de K3s, charts, controllers, operators e [imagens](../deployment/image-lifecycle/) foram inventariadas sem atualização automática apenas por estarem disponíveis.
- [ ] Suporte, correções de segurança, compatibilidade e impacto operacional foram avaliados para priorizar as atualizações.
- [ ] Correções urgentes seguem um fluxo extraordinário controlado e não aguardam a revisão mensal quando o risco não permite.
- [ ] Atualizações aprovadas passaram por homologação, backup, mudança controlada e validação posterior.
- [ ] As versões efetivamente implantadas e o resultado da mudança foram registrados.
- [ ] Capacidade, requests, limits, retenção de logs e armazenamento do monitoramento foram reavaliados.
- [ ] Receptores de alertas, responsáveis, runbooks e caminhos de escalonamento continuam válidos.
- [ ] Atualizações e reinicializações dos hosts foram planejadas sem comprometer quorum ou disponibilidade.

### Trimestral ou conforme a criticidade

- [ ] Um [teste de restauração completo](../../operations/backup-and-recovery/) foi executado e cronometrado em ambiente isolado.
- [ ] RPO e RTO continuam compatíveis com o resultado do teste e com as necessidades atuais.
- [ ] Um teste de alertas confirmou geração, roteamento, recebimento, escalonamento e encerramento.
- [ ] Acessos, credenciais, responsáveis e contatos foram revisados.
- [ ] Cenários de perda de nó, volume, credencial e cluster foram exercitados ou revisados.
- [ ] Dependências abandonadas, versões fora de suporte e necessidade futura de capacidade possuem plano de ação.

## 3. Antes e depois de uma manutenção

Use o [runbook de manutenção e mudanças](../../operations/maintenance-runbook/) para preencher baseline, responsáveis, janela, etapas, critérios objetivos, log de timestamps, rollback, observação posterior e fechamento.

### Antes

- [ ] Escopo, impacto, responsável, janela e comunicação da mudança estão registrados.
- [ ] Compatibilidade e ordem entre K3s, Kubernetes, CRDs, controllers, charts e workloads foram verificadas.
- [ ] Backups necessários terminaram, foram copiados externamente e estão dentro do RPO.
- [ ] Critérios para continuar, interromper ou reverter a mudança estão definidos.
- [ ] Quorum, réplicas, PodDisruptionBudgets, capacidade livre e possibilidade de drenar os nós foram conferidos.

### Durante

- [ ] A mudança respeita a ordem planejada e a saúde é verificada entre as etapas.
- [ ] Nenhuma etapa avança depois que um critério de interrupção é atingido.
- [ ] Desvios e decisões são registrados enquanto o contexto ainda está disponível.

### Depois

- [ ] Nós, workloads, probes, métricas, alertas, armazenamento e funcionalidades críticas foram validados.
- [ ] A versão e a configuração observadas correspondem ao estado desejado.
- [ ] O rollback continua possível até o encerramento da janela de observação.
- [ ] Resultado, incidentes, duração e ações pendentes foram registrados.

## Procedimentos relacionados

- [Validação pós-instalação](../../operations/k3s-post-install-checklist/)
- [Backup, atualização e remoção de nós](../../operations/k3s-cluster-maintenance/)
- [Longhorn e armazenamento persistente](../../kubernetes/extensions/longhorn/)
- [Templates de GitOps e monitoramento](../deployment/templates/)
- [Argo CD](../deployment/argo-cd/) e [bootstrap GitOps](../deployment/gitops-bootstrap/)
- [Identidade e RBAC](../../kubernetes/security/identity-and-rbac/)
- [NetworkPolicy](../../kubernetes/networking/network-policies/)
- [Prontidão de workloads para produção](../../kubernetes/workloads/production-readiness/)
- [Ciclo de vida de imagens](../deployment/image-lifecycle/)
- [Observabilidade e alertas](../../operations/observability-and-alerting/)
- [Backup e recuperação](../../operations/backup-and-recovery/)
- [Runbook de manutenção e mudanças](../../operations/maintenance-runbook/)

## Fontes e leitura adicional

- [Probes de startup, readiness e liveness — Kubernetes](https://kubernetes.io/docs/concepts/workloads/pods/probes/): define o comportamento e as consequências de cada tipo de probe.
- [Imagens de containers — Kubernetes](https://kubernetes.io/docs/concepts/containers/images/): documenta nomes, tags, digests e políticas de pull.
- [Gerenciamento de recursos dos containers — Kubernetes](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/): explica requests, limits, agendamento e pressão de recursos.
- [Observabilidade no Kubernetes](https://kubernetes.io/docs/concepts/cluster-administration/observability/): organiza métricas, logs e traces usados para compreender o estado do sistema.
- [Arquitetura de logs — Kubernetes](https://kubernetes.io/docs/concepts/cluster-administration/logging/): apresenta as alternativas para preservar e centralizar logs além do ciclo de vida dos Pods.
- [Disrupções e PodDisruptionBudgets — Kubernetes](https://kubernetes.io/docs/concepts/workloads/pods/disruptions/): distingue disrupções voluntárias e involuntárias e define os limites de um PDB.
