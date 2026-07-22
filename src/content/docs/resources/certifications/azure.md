---
title: "Certificações Azure: AZ-104, AZ-305, AZ-400 e AZ-700"
description: As certificações Azure relevantes para operar Kubernetes gerenciado (AZ-104, AZ-305, AZ-400, AZ-700), domínios auditados contra os study guides oficiais, a mudança de blueprint de AZ-400/AZ-700 em 27 de julho de 2026, e o estado atual do Applied Skills de AKS.
sidebar:
  order: 4
---

> **Para quem é:** quem já opera ou pretende operar workloads no Azure (incluindo AKS) e quer saber qual certificação cobre o quê antes de escolher uma trilha.

Todos os domínios e percentuais desta página foram auditados contra os study guides oficiais em `learn.microsoft.com/credentials/certifications/resources/study-guides/` em 2026-07-22; confira a fonte de cada certificação antes de estudar, porque a Microsoft revisa o blueprint de cada exame periodicamente e publica a data exata da mudança.

## AZ-104, AZ-305, AZ-400 e AZ-700, por domínio auditado

Todas seguem o mesmo formato geral: múltipla escolha/múltipla resposta, pontuação em escala com nota mínima de aprovação de 700, certificações associate/expert com renovação anual gratuita via avaliação online.

| Certificação | Nível | Domínios e peso |
| --- | --- | --- |
| **AZ-104** (Administrator) | Associate | Compute 20-25%, identidades/governança 20-25%, storage 15-20%, rede virtual 15-20%, monitoramento/manutenção 10-15% |
| **AZ-305** (Solutions Architect Expert) | Expert | Infraestrutura 30-35%, identidade/governança/monitoramento 25-30%, armazenamento de dados 20-25%, continuidade de negócio 15-20% |
| **AZ-400** (DevOps Engineer Expert) | Expert | Pipelines de build/release 50-55%, processos/comunicação 10-15%, controle de fonte 10-15%, segurança/compliance 10-15%, instrumentação 5-10% |
| **AZ-700** (Network Engineer Associate) | Associate | Infraestrutura de rede central 25-30%, conectividade 20-25%, entrega de aplicação 15-20%, segurança de rede 15-20%, acesso privado a serviços 10-15% |

**AZ-400 e AZ-700 mudam de blueprint em 27 de julho de 2026** (confirmado diretamente nos study guides oficiais, seção "Skills measured as of July 27, 2026"): no AZ-400, a nova versão concentra mais da metade da prova (50-55%) em pipelines de build/release, um aumento de peso frente a versões anteriores; para o AZ-700, a estrutura de domínios muda de forma menos drástica, mas ainda assim vale conferir a versão vigente na data real da prova, não a versão estudada meses antes. Se a prova for feita perto dessa data de transição, confirme explicitamente qual versão do blueprint está em vigor no momento do agendamento, não a versão estudada meses antes.

Nenhuma das quatro cobre AKS como domínio dedicado; o serviço aparece como um dos muitos tópicos de compute dentro de domínios mais amplos (AZ-104 em "provisionar e gerenciar containers", AZ-305 em "recomendar uma solução baseada em container"), o mesmo padrão generalista já visto nas certificações AWS.

> **Recomendação editorial do notebook (não fato oficial):** para o AZ-104, a distinção mais recorrente é Azure RBAC (papéis sobre recursos) vs. papéis administrativos do Entra ID (papéis sobre a própria identidade), e Availability Set (dentro de um datacenter) vs. Availability Zone (entre datacenters fisicamente separados); determinar o escopo (management group / subscription / resource group / recurso) antes de responder evita a maior parte dos erros de RBAC/Policy. Para o AZ-305, a prova é de recomendação, não de implementação: montar mentalmente uma tabela de requisitos (protocolo, alcance, latência, resiliência, estado, compliance, operação, custo) antes de escolher um serviço específico rende mais do que decorar a lista de serviços. Para o AZ-400, dominar os equivalentes entre GitHub e Azure DevOps (Actions vs. Pipelines, branch protection vs. environment approval) é essencial, já que a prova cobre os dois ecossistemas. Para o AZ-700, desenhar mentalmente o caminho completo do pacote, incluindo o caminho de volta, evita o erro mais comum de esquecer que peering de VNet não é transitivo por padrão.

## Applied Skills: o estado real do credencial de AKS

O item de Applied Skills mais citado para quem opera AKS ("Deploy containers by using Azure Kubernetes Service", código `APL-1001`) **está oficialmente retirado desde 17/06/2024**, confirmado diretamente na página oficial da Microsoft ("This Applied Skill assessment has been retired"). Isso significa que, até a escrita (2026-07-22), essa credencial específica não pode mais ser obtida; a busca por um substituto direto de AKS na linha Applied Skills não encontrou um credencial ativo equivalente no momento desta verificação. Antes de se planejar em torno de um Applied Skills de AKS, confira o [catálogo atual de Applied Skills da Microsoft](https://learn.microsoft.com/en-us/credentials/browse/?credential_types=applied%20skills&products=azure-kubernetes-service) para o estado vigente, porque a linha Applied Skills é adicionada e retirada com mais frequência que uma certificação `AZ-` tradicional.

> **Recomendação editorial do notebook (não fato oficial):** mesmo com a credencial específica retirada, o conteúdo que ela cobria (fluxo ACR → identidade → AKS → scheduling → Service → escala) continua sendo a sequência prática correta para operar AKS de verdade, e vale como roteiro de estudo independente de qual credencial formal (se alguma) estiver disponível no momento. As pegadinhas mais citadas nesse fluxo são: imagem publicada no node pool errado (Linux vs. Windows), falta de `nodeSelector`/`toleration` fazendo o Pod nunca ser agendado, o AKS sem permissão de pull configurada no ACR (`AcrPull` não é automático), e HPA configurado sem `resources.requests` definidos ou sem o metrics server instalado, casos em que o autoscaler simplesmente não tem dado para agir.

## Páginas relacionadas

- [Mapa de certificações](../): a distinção geral entre certificação, badge e Applied Skill.

## Referências

- [Study guide for AZ-104 (Microsoft Learn)](https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/az-104): domínios vigentes desde 17/04/2026 (até a escrita, 2026-07-22).
- [Study guide for AZ-305 (Microsoft Learn)](https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/az-305): domínios vigentes desde 17/04/2026 (até a escrita, 2026-07-22).
- [Study guide for AZ-400 (Microsoft Learn)](https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/az-400): domínios vigentes a partir de 27/07/2026 (até a escrita, 2026-07-22).
- [Study guide for AZ-700 (Microsoft Learn)](https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/az-700): domínios vigentes a partir de 27/07/2026 (até a escrita, 2026-07-22).
- [Microsoft Applied Skills: Deploy containers by using Azure Kubernetes Service](https://learn.microsoft.com/en-us/credentials/applied-skills/deploy-containers-by-using-azure-kubernetes-service): página oficial confirmando a retirada em 17/06/2024.
