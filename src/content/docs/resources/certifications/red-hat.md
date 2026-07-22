---
title: "Certificações Red Hat: da EX180 às especializações de OpenShift"
description: A trilha prática Red Hat (EX180, EX280, EX288, EX380) e as especializações (EX430, EX432, EX370), todas performance-based com o requisito de que a configuração sobreviva a reinicializações, versões de OpenShift auditadas por exame (nem todas seguem a mesma versão).
sidebar:
  order: 5
---

> **Para quem é:** quem já opera OpenShift ou está avaliando a trilha Red Hat como validação formal desse conhecimento, e quer entender por que essas provas são estruturalmente diferentes das de múltipla escolha já vistas nas páginas anteriores.

Todas as provas desta página são performance-based (avaliação em laboratório real, contra um cluster ao vivo), confirmado pela própria Red Hat página a página; nenhuma é múltipla escolha. Um característica documentada por terceiros de forma consistente para o formato performance-based da Red Hat, e já citada no [mapa de certificações](../), é que a configuração final precisa sobreviver a uma reinicialização sem intervenção manual, não só estar correta no momento em que o candidato termina a tarefa; não encontrei essa frase exata na página oficial de cada exame individual, então trato como característica bem documentada do formato, não como citação literal de um texto oficial específico.

## A trilha principal: EX180 → EX280 → EX288 → EX380

| Certificação | Foco |
| --- | --- |
| **EX180** | Fundamentos: `oc`, projetos, imagens, deploy, escala, exposição de serviços. |
| **EX280** (Administrator) | Operação da plataforma, RBAC, monitoramento, componentes específicos do OpenShift. Base para o Red Hat Certified Architect (RHCA). Confirmado como baseado em **OpenShift Container Platform 4.18** (auditado em 2026-07-22). |
| **EX288** (Advanced Developer) | Deploy de aplicações, builds, health checks, registry interno. |
| **EX380** (Advanced System Administrator) | Escala empresarial: planejar, implementar e gerenciar deployments OpenShift de grande porte; também conta para o RHCA. |

Não confirmei uma versão de OpenShift específica publicada para EX180, EX288 e EX380 nesta verificação; ao contrário de EX280 (4.18 confirmado) e EX370 (4.16 confirmado, ver abaixo), nem todo exame do portfólio Red Hat publica a versão de forma tão explícita quanto os dois anteriores, e a versão pode diferir entre exames do mesmo portfólio, não seguir um número único para todo o catálogo. Confirme a versão vigente na página oficial de cada exame antes de agendar.

> **Recomendação editorial do notebook (não fato oficial):** o erro mais caro nessas provas não costuma ser não saber o comando, é o estado quase correto: projeto/namespace errado, uma Route confundida com o Service que ela expõe, editar diretamente um recurso gerenciado por um controller (revertido na próxima reconciliação), ou uma imagem que presume rodar como root/UID fixo, incompatível com o modelo padrão do OpenShift de UID arbitrário. Validar função **e** persistência (a configuração continua correta depois de simular uma reinicialização ou reconciliação) ao final de cada tarefa, não só no momento em que ela parece pronta, é a prática mais citada para reduzir esse tipo de erro.

## Especializações: EX430, EX432 e EX370

**EX430** (Advanced Cluster Security) valida a capacidade de proteger clusters OpenShift usando Red Hat Advanced Cluster Security for Kubernetes (RHACS): políticas de segurança, gestão de vulnerabilidades, enforcement de compliance. Não encontrei uma versão de RHACS publicada de forma tão explícita quanto as duas certificações seguintes; confira a página oficial antes de estudar.

**EX432** (Advanced Cluster Management) valida planejamento, deploy e gestão do Red Hat Advanced Cluster Management (RHACM), a ferramenta de governança e GitOps multicluster da Red Hat. Confirmado como baseado em **OpenShift Container Platform 4.18 e Red Hat Advanced Cluster Management 2.13** (auditado em 2026-07-22). Vale notar que a Red Hat já teve um exame anterior de escopo parecido (EX480, MultiCluster Management), hoje retirado do portfólio; EX432 é o caminho atual para essa área.

**EX370** (OpenShift Data Foundation) valida a criação e gestão de storage para aplicações em container usando o Red Hat OpenShift Data Foundation (ODF). Confirmado como baseado em **Red Hat OpenShift Data Foundation 4.16 e OpenShift Container Platform 4.16** (auditado em 2026-07-22), uma versão de OpenShift **diferente** da usada por EX280/EX432 (4.18): cada exame do portfólio versiona de forma independente, não existe uma única "versão do OpenShift da Red Hat" válida para todo o catálogo de certificações ao mesmo tempo.

> **Recomendação editorial do notebook (não fato oficial):** para EX430, a distinção mais recorrente é política de segurança em tempo de build vs. deploy vs. runtime, e a diferença entre um alerta (RHACS detectou e registrou) e enforcement de fato (RHACS bloqueou a ação). Para EX432, a sequência conceitual é sempre a mesma: um recurso declarado no hub → um mecanismo de distribuição (placement) → o estado efetivo observado em cada cluster gerenciado; confundir "compliant" (a política foi avaliada como satisfeita) com "remediated" (uma ação corretiva foi de fato aplicada) é o erro mais citado. Para EX370, o erro mais caro é parar a validação assim que um volume mostra status `Bound`: `Bound` só confirma que o PVC foi satisfeito por um PV, não que a aplicação consegue de fato escrever, remontar ou sobreviver a uma reinicialização; validar essas três coisas explicitamente é o que a prova cobra na prática.

## Páginas relacionadas

- [Mapa de certificações](../): a confirmação geral de que provas Red Hat são performance-based, não múltipla escolha.

## Referências

- [Red Hat Certified System Administrator in OpenShift exam (EX280)](https://www.redhat.com/en/services/training/red-hat-certified-openshift-administrator-exam): versão OpenShift 4.18 (até a escrita, 2026-07-22).
- [Red Hat Certified Specialist in OpenShift Advanced Cluster Management exam (EX432)](https://www.redhat.com/en/services/training/ex432-red-hat-certified-specialist-openshift-advanced-cluster-management-exam): versões OpenShift 4.18 / RHACM 2.13 (até a escrita, 2026-07-22).
- [Red Hat Certified Specialist in OpenShift Data Foundation exam (EX370)](https://www.redhat.com/en/services/training/ex370-red-hat-certified-specialist-in-openshift-data-foundation-exam): versões ODF 4.16 / OpenShift 4.16 (até a escrita, 2026-07-22).
- [Red Hat Certified Advanced System Administrator in OpenShift exam (EX380)](https://www.redhat.com/en/services/training/ex380-certified-specialist-openshift-automation-exam): descrição oficial do escopo (até a escrita, 2026-07-22).
- [Red Hat Certified Specialist in OpenShift Advanced Cluster Security exam (EX430)](https://www.redhat.com/en/services/training/ex430-red-hat-certified-specialist-openshift-advanced-cluster-security-exam): descrição oficial do escopo (até a escrita, 2026-07-22).
- [Red Hat: EX200 (RHCSA)](https://www.redhat.com/en/services/certification/rhcsa): confirmação do formato "performance-based" característico da Red Hat, já citado no mapa de certificações.
