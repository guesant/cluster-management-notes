---
title: "Certificações AWS: SAA, SOA, DOP, SCS e o EKS Knowledge Badge"
description: As quatro certificações AWS relevantes para operar Kubernetes gerenciado (SAA-C03, SOA-C03, DOP-C02, SCS-C03), domínios auditados contra os exam guides oficiais, e por que o EKS Knowledge Badge não é uma certificação profissional.
sidebar:
  order: 3
---

> **Para quem é:** quem já opera ou pretende operar workloads na AWS (incluindo EKS) e quer saber qual das quatro certificações principais cobre o quê antes de escolher uma trilha.

Todos os domínios e percentuais desta página foram auditados contra os exam guides oficiais em `docs.aws.amazon.com/aws-certification/` em 2026-07-22; confira a fonte de cada certificação antes de estudar, porque a AWS revisa exam guides periodicamente (o SOA-C03, por exemplo, já aparece com o nome atualizado "AWS Certified CloudOps Engineer - Associate" nos documentos mais recentes, tendo sido "SysOps Administrator - Associate" no passado, mesmo código de exame).

## As quatro certificações, por domínio auditado

Todas as quatro seguem o mesmo formato de prova: múltipla escolha e múltipla resposta (não performance-based), pontuação em escala de 100 a 1.000, modelo de pontuação compensatório (não é preciso passar em cada domínio individualmente, só na prova como um todo).

| Certificação | Nível | Domínios e peso |
| --- | --- | --- |
| **SAA-C03** (Solutions Architect Associate) | Associate | Arquiteturas seguras 30%, resilientes 26%, de alto desempenho 24%, otimizadas em custo 20% |
| **SOA-C03** (CloudOps Engineer/SysOps Administrator Associate) | Associate | Monitoramento/remediação/performance 22%, confiabilidade/continuidade 22%, deploy/provisionamento/automação 22%, rede 18%, segurança/compliance 16% |
| **DOP-C02** (DevOps Engineer Professional) | Professional | SDLC automation 22%, config. management/IaC 17%, segurança/compliance 17%, resiliência 15%, monitoramento/logging 15%, resposta a incidentes 14% |
| **SCS-C03** (Security Specialty) | Specialty | IAM 20%, infraestrutura 18%, proteção de dados 18%, detecção 16%, resposta a incidentes 14%, fundamentos/governança 14% |

SAA-C03 e SCS-C03 têm 65 perguntas (50 pontuadas, 15 não pontuadas usadas para calibração futura, sem identificação de quais são quais), 130 minutos. Nenhuma das quatro cobre EKS como foco central da prova; EKS aparece como um dos muitos serviços dentro de domínios mais amplos (arquitetura, operação, automação, segurança), coerente com o próprio caráter generalista dessas certificações.

> **Recomendação editorial do notebook (não fato oficial):** o padrão mais citado em todas as quatro provas é a presença de qualificadores textuais no enunciado ("mais econômico", "menor esforço operacional", "sem alterar a aplicação", "mínimo privilégio") que eliminam a segunda resposta tecnicamente correta; sublinhar mentalmente esses termos antes de escolher a alternativa reduz o erro mais comum de múltipla escolha nessas provas. Para o SAA-C03, a distinção mais recorrente é multi-AZ (tolerância a falha dentro de uma região) vs. multi-region (continuidade entre regiões), e Security Group (stateful) vs. NACL (stateless). Para o SOA-C03, a ordem prática é reunir evidência antes de aplicar uma correção (CloudWatch Logs/Metrics/Agent antes de qualquer ação de remediação). Para o DOP-C02, a heurística mais citada é privilegiar automação repetível e auditável sobre uma correção manual pontual, mesmo quando a manual pareceria mais rápida naquele momento. Para o SCS-C03, a regra central é que um explicit deny sempre vence sobre qualquer allow, em qualquer camada (SCP, boundary, IAM); em cenários envolvendo EKS, somar IAM (acesso à AWS) com RBAC (acesso ao cluster) como duas camadas independentes, não uma sobreposta à outra.

## Amazon EKS Knowledge Badge: credencial de aprendizagem, não certificação profissional

O **Amazon EKS Knowledge Badge** é obtido através de uma avaliação no AWS Skill Builder, emitida pela "AWS Training and Certification" como uma "Training Badge", não uma "AWS Certified" formal; a própria AWS não lista o EKS Knowledge Badge junto das quatro certificações acima no portfólio principal de certificações, uma distinção que importa para quem está decidindo o que registrar como certificação profissional num currículo (já discutida em termos gerais no [mapa de certificações](../)).

> **Recomendação editorial do notebook (não fato oficial):** as pegadinhas mais citadas sobre EKS combinam exatamente a mesma armadilha do SCS-C03 aplicada ao cluster: permitir uma ação no IAM não equivale a ter RBAC dentro do cluster, e vice-versa; a role atribuída a um nó não é a mesma coisa que a identidade de um Pod (IRSA ou Pod Identity resolvem isso, cada um com seu próprio modelo de confiança). Outra fonte comum de erro é confundir o Cluster Autoscaler/Karpenter (que adicionam ou removem nós) com o HPA (que escala réplicas de um workload dentro da capacidade já existente); os dois resolvem escala em camadas diferentes e frequentemente precisam operar juntos, não um no lugar do outro.

## Páginas relacionadas

- [Mapa de certificações](../): a distinção geral entre certificação, badge e Applied Skill.

## Referências

- [AWS Certified Solutions Architect - Associate (SAA-C03): exam guide oficial](https://docs.aws.amazon.com/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html): domínios e formato (até a escrita, 2026-07-22).
- [AWS Certified CloudOps Engineer - Associate (SOA-C03): exam guide oficial](https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03.html): domínios e formato (até a escrita, 2026-07-22).
- [AWS Certified DevOps Engineer - Professional (DOP-C02): exam guide oficial](https://docs.aws.amazon.com/aws-certification/latest/devops-engineer-professional-02/devops-engineer-professional-02.html): domínios e formato (até a escrita, 2026-07-22).
- [AWS Certified Security - Specialty (SCS-C03): exam guide oficial](https://docs.aws.amazon.com/aws-certification/latest/security-specialty-03/security-specialty-03.html): domínios e formato (até a escrita, 2026-07-22).
- [AWS Certification Digital Badges](https://aws.amazon.com/certification/certification-digital-badges/): distinção entre badges de aprendizagem e certificações "AWS Certified".
