---
title: Ferramentas de automação e orquestração
description: Catálogo de ferramentas de automação que complementam a operação manual deste notebook — Ansible e just — com o que avaliar antes de adotar cada uma.
sidebar:
  order: 1
---

> **Para quem é:** quem quer repetir um procedimento de host contra vários hosts de uma vez (Ansible), ou empacotar os comandos que já usa em atalhos nomeados e documentados (just).

## Ansible: automação de configuração via SSH

Ansible aplica configuração em um conjunto de hosts via SSH, sem exigir um agente instalado permanentemente. Veja [modelo mental do Ansible](../../../learn/automation/ansible-model/) para como o control node, o inventário, os módulos e a idempotência se relacionam antes de instalar.

```bash
sudo apt install ansible-core

ansible --version
```

**Quando usar:** aplicar o mesmo procedimento (pacotes, arquivos de configuração, serviços) a vários hosts de forma repetível e auditável, em vez de repetir manualmente os passos de um guia como [preparar um servidor Debian](../../../guides/tasks/host/prepare-debian-server/) host por host.

**Modelo de acesso e privilégios:** o `ansible-core` no control node só precisa de acesso SSH aos hosts gerenciados, com a mesma identidade e as mesmas chaves que uma sessão `ssh` manual usaria; veja [clientes e gateways de acesso remoto](../remote-access/remote-access-tools/) para o catálogo de acesso SSH. Tarefas que exigem privilégio elevado no host de destino usam `become: true`, equivalente a rodar o comando correspondente com `sudo`.

**Riscos:** um playbook mal escrito, sem os módulos declarativos corretos (veja [idempotência como contrato](../../../learn/automation/ansible-model/#idempotência-como-contrato)), pode reexecutar uma ação destrutiva a cada rodada em vez de convergir para um estado estável. Rode com `--check --diff` antes de aplicar de fato contra hosts de produção, para revisar o que mudaria sem alterar nada ainda.

---

## just: executor de tarefas (task runner)

`just` lê um arquivo `justfile` na raiz do projeto e expõe cada bloco nomeado como um comando (`just <nome>`), documentando e padronizando os comandos que um projeto usa com frequência, sem a sintaxe historicamente propensa a erro do Make (indentação por tab obrigatória, `.PHONY` manual).

```bash
# Via Cargo, se o toolchain Rust já estiver instalado
cargo install just

# Alternativa: baixar o binário da arquitetura correspondente na página de
# releases do projeto e validar o checksum publicado antes de instalar
```

O próprio `justfile` deste repositório é um exemplo real:

```just
default:
    @just --list

up:
    just _compose up --detach app

down:
    just _compose down

shell: up
    just _compose exec app bash
```

**Quando usar:** documentar e padronizar os comandos do dia a dia de um projeto (subir um ambiente, rodar testes, abrir um shell dentro de um container) como atalhos nomeados, descobríveis com `just --list`, em vez de manter esses comandos espalhados apenas em um README.

**Considerações:** a recipe `default` (sem argumento, como no exemplo acima) roda quando `just` é chamado sem nenhum nome de recipe; `shell: up` declara uma dependência, então `just shell` executa `up` antes de `shell` automaticamente. `just` não substitui um orquestrador de automação como o Ansible: ele roda comandos locais ao host onde é invocado, sem inventário, sem SSH e sem o conceito de convergência para um estado declarado.

## Referências

- [Ansible: documentação oficial](https://docs.ansible.com/ansible/latest/index.html): instalação, `ansible-playbook`, módulos e boas práticas.
- [just: repositório oficial](https://github.com/casey/just): sintaxe completa de recipes, variáveis e releases.
