---
title: "Qualidade em Ansible: ansible-lint, Molecule e execução segura"
description: O que ansible-lint pega antes de rodar, o que Molecule testa (e o custo real de manter isso), e estratégias para reduzir o raio de impacto de um playbook em produção (serial, --limit, check mode).
sidebar:
  order: 3
---

> **Para quem é:** quem já escreveu e validou um primeiro playbook idempotente (a página anterior desta trilha) e precisa saber como pegar erro antes de rodar contra produção, e como limitar o estrago se algo sair errado mesmo assim.

## ansible-lint: pegar erro antes de executar

`ansible-lint` analisa playbooks e roles estaticamente, sem executar nada, sinalizando padrões que costumam causar problema: uma tarefa sem `name`, uso de `command`/`shell` onde um módulo declarativo resolveria o mesmo caso de forma idempotente (o problema já discutido na página anterior), variáveis não citadas de forma consistente, permissões de arquivo definidas de forma implícita. É o equivalente, para Ansible, do `shellcheck` já coberto na trilha de shells deste notebook: uma ferramenta que verifica a promessa do código (aqui, "este playbook é idempotente e seguro") contra o que o código de fato faz.

Rodar `ansible-lint` como parte do fluxo de revisão, antes de qualquer execução contra um host real, pega a classe de erro mais barata de corrigir: a que nunca chega a rodar contra produção.

## Molecule: o que ele testa, e o custo real de manter

**Molecule** testa roles de ponta a ponta: cria um ambiente efêmero (tipicamente um container, via driver Docker ou Podman), aplica a role contra ele, roda verificações (`idempotence`, que aplica a role duas vezes e falha se a segunda execução reportar `changed`, exatamente a validação manual já feita na página anterior, automatizada), e destrói o ambiente ao final. É a diferença entre confiar que uma role é idempotente porque parece correta e provar isso a cada mudança, de forma repetível, sem depender de um host real disponível para teste.

O custo real não é o Molecule em si (a ferramenta é gratuita e razoavelmente direta de configurar), é o tempo de manutenção: cada cenário de teste precisa de sua própria configuração (`molecule.yml`), o ambiente efêmero de container não reproduz 100% um host real (diferenças de systemd rodando ou não dentro de um container, por exemplo, um problema real e citado com frequência pela própria comunidade Ansible), e testes que envolvem múltiplos hosts interagindo exigem cenários mais elaborados que testes de host único. Adotar Molecule vale a pena para roles reutilizadas em múltiplos projetos ou mantidas por mais de uma pessoa, onde o custo de uma regressão silenciosa supera o custo de manter os testes; para um playbook pequeno e usado por um único operador, a validação manual de idempotência (rodar duas vezes, conferir `changed=0`) já cobre boa parte do mesmo risco a um custo de manutenção bem menor.

## Estratégias de execução segura contra produção

Três mecanismos reduzem o raio de impacto de um playbook antes dele rodar contra o parque inteiro de uma vez:

**`serial`**, declarado no nível da play, limita quantos hosts o Ansible processa por vez, em vez do padrão (todos em paralelo, até o limite de forks). `serial: 1` aplica a mudança a um host, espera terminar, só então avança para o próximo; `serial: "25%"` processa em lotes proporcionais ao tamanho do inventário. Isso é o que torna um erro descoberto no meio de uma execução um problema de um host (ou de um lote pequeno), não do parque inteiro simultaneamente.

**`--limit`**, passado na linha de comando, restringe a execução a um subconjunto de hosts do inventário sem precisar editar o playbook ou o inventário para isso: `ansible-playbook site.yml --limit node01` roda só contra `node01`, útil tanto para testar uma mudança num único host antes de generalizar quanto para reexecutar contra um host específico que falhou numa execução anterior maior, sem tocar nos que já passaram.

**Check mode em produção** (`--check`, já visto na página anterior) tem uma limitação real que vale registrar antes de depender dele como rede de segurança: módulos que dependem de estado criado por uma tarefa anterior na mesma execução podem se comportar de forma imprevisível em modo simulação, porque essa tarefa anterior nunca de fato rodou; `--check` é confiável para prever o efeito de uma tarefa isolada, menos confiável para prever o efeito de uma sequência de tarefas interdependentes. Usar `--check` como último passo antes de uma execução real contra produção continua sendo uma prática sólida, mas não substitui `serial`/`--limit` como rede de segurança para o caso em que a previsão do modo simulação diverge do comportamento real.

## Páginas relacionadas

- [Escrever e validar o primeiro playbook Ansible](../../../guides/tasks/automation/first-ansible-playbook/): a validação manual de idempotência que Molecule automatiza.
- [Portabilidade de scripts shell](../../unix/shell-scripting-portability/): `shellcheck`, o equivalente de `ansible-lint` para scripts shell.

## Referências

- [ansible-lint (documentação oficial)](https://ansible.readthedocs.io/projects/lint/): regras padrão e como integrar ao fluxo de revisão.
- [Molecule (documentação oficial)](https://ansible.readthedocs.io/projects/molecule/): drivers de ambiente efêmero e o cenário `idempotence`.
- [Ansible: Delegation, rolling updates, and local actions](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_delegation.html): `serial` e execução em lotes.
- [Ansible: Patterns: targeting hosts and groups](https://docs.ansible.com/ansible/latest/inventory_guide/intro_patterns.html): `--limit` e padrões de seleção de host.
