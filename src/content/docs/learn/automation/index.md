---
title: Automação
description: Trilha de leitura desta seção, do modelo mental do Ansible à estrutura de um projeto real e às práticas que garantem qualidade antes de rodar contra produção.
sidebar:
  order: 0
---

> **Para quem é:** quem nunca usou Ansible e precisa entender o modelo, a estrutura de um projeto real, e como validar qualidade antes de confiar num playbook em produção.

Esta seção segue a ordem natural de quem está aprendendo Ansible do zero: primeiro o modelo mental (control node, inventário, módulos, idempotência como contrato), depois como esses elementos se organizam num projeto real (playbooks, roles, collections, Vault), e por fim as práticas que garantem que um playbook continua correto ao longo do tempo (lint, testes automatizados, execução segura contra produção). O [primeiro playbook prático](../../guides/tasks/automation/first-ansible-playbook/), em `guides/tasks/`, aplica o modelo mental desta seção a um caso real, entre a primeira e a terceira página.

## Trilha

1. [Modelo mental do Ansible](ansible-model/) — control node, inventário, módulos e idempotência como contrato.
2. [Estrutura de um projeto Ansible: playbooks, roles e Vault](ansible-structure/) — como esses elementos se organizam à medida que um projeto cresce.
3. [Qualidade em Ansible: ansible-lint, Molecule e execução segura](ansible-quality/) — o que verificar antes de confiar num playbook em produção.
