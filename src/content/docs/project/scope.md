---
title: Escopo do projeto
description: O que o infrastructure-and-cluster-notebook cobre hoje e para onde está indo, para quem é útil e o que fica fora do escopo.
sidebar:
  order: 1
---

O `infrastructure-and-cluster-notebook` reúne anotações pessoais sobre infraestrutura, containers
e clusters: conceitos, blueprints, guias passo a passo, operação e catálogo de ferramentas (ver
[Política de conteúdo](../content-policy/) para como o conteúdo é organizado). O foco atual e mais
completo é criar e operar clusters K3s de nó único (*single-node*) ou multinó (*multi-node*); o
restante do escopo está em expansão. Veja o que ainda falta em
[Decisões do projeto](../decisions/).

## O que este projeto cobre hoje

- Hosts Debian ou Ubuntu com `systemd`, em arquiteturas `amd64` e `arm64`.
- Instalação, expansão e operação de clusters K3s (servidores e agentes).
- Hardening básico do host: firewall, SSH e Fail2Ban.
- Rede, segurança, extensões e prontidão de workloads no Kubernetes/K3s.
- Estratégias de implantação (GitOps com Argo CD) e gestão de segredos (Infisical, SOPS, Sealed Secrets, External Secrets Operator, OpenBao).
- Rotinas operacionais: observabilidade, backup e recuperação, manutenção.
- Um catálogo inicial de ferramentas e comandos de referência (`toolbox/`).
- Um blueprint completo de cluster Docker Swarm (rede overlay, secrets, volumes, deploy e
  recuperação de desastre), como alternativa ao K3s para quem já roda Docker e quer simplicidade
  operacional acima de flexibilidade.

As premissas técnicas detalhadas (usuário assumido, formato dos blocos de comando, versões de
referência) estão em [Escopo, convenções e versões](../../reference/conventions/).

## Para quem é

Para quem administra ou estuda clusters K3s pequenos (laboratórios pessoais, projetos paralelos
ou ambientes de baixa escala) e já tem familiaridade básica com administração Linux e linha de
comando.

## O que fica fora do escopo

- Não é um guia de suporte ou uma matriz de compatibilidade homologada para produção em larga
  escala.
- Não é material oficial da Rancher, SUSE, CNCF ou de qualquer projeto citado: é conteúdo
  independente que referencia as fontes oficiais sempre que possível.
- Outras distribuições Kubernetes (RKE2, kubeadm) e serviços gerenciados (EKS, GKE, AKS) têm
  apenas cobertura conceitual em `learn/` (comparações e critérios de decisão, como
  [RKE2 vs. K3s](../../learn/clusters/rke2-vs-k3s/) e
  [Kubernetes gerenciado vs. self-hosted](../../learn/clusters/managed-vs-selfhosted/)), sem um
  blueprint operacional completo equivalente ao de K3s; isso está planejado como expansão futura.

Veja também o [aviso sobre uso de IA na elaboração deste conteúdo](../disclaimer/).
