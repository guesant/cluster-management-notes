---
title: Escrever e validar o primeiro playbook Ansible
description: Um inventário mínimo de um host, um playbook idempotente real aplicando parte da preparação de um servidor Debian, e como confirmar que a segunda execução não reporta nenhuma mudança.
sidebar:
  order: 1
---

> **Pré-requisitos:** um control node com `ansible-core` instalado (idealmente num ambiente isolado, como um container, sem privilégios desnecessários), acesso SSH ao host alvo (ou o próprio control node como alvo, via `ansible_connection=local`, para o primeiro teste).
> **Versões testadas:** ansible-core 2.17.

Este procedimento aplica, via Ansible, uma parte real da preparação de host já coberta em [preparar um servidor Debian](../../host/prepare-debian-server/): a etapa de [journal persistente](../../host/configure-persistent-journal/). O objetivo não é reescrever aquele procedimento; é mostrar como o [modelo mental](../../../../learn/automation/ansible-model/) e a [estrutura de projeto](../../../../learn/automation/ansible-structure/) já descritos nesta trilha se materializam num playbook real, validado por execução repetida, não só por leitura do YAML.

## O que isto modifica

No host alvo: cria o diretório `/var/log/journal` (se ainda não existir) e ajusta a diretiva `Storage=persistent` em `/etc/systemd/journald.conf`, reiniciando `systemd-journald` só quando essa diretiva de fato muda. Não modifica nenhum outro serviço nem remove configuração existente fora dessa diretiva específica.

## Inventário mínimo

```ini
# inventory.ini
[k3s_nodes]
node01 ansible_host=203.0.113.10 ansible_user=admin
```

**Considerações:**

- Um único host já é suficiente para validar o playbook antes de aplicá-lo a um grupo maior; adicionar hosts ao grupo `k3s_nodes` depois não exige mudança nenhuma no playbook.
- Para testar contra o próprio control node em vez de um host remoto, substitua a linha por `node01 ansible_connection=local` (sem `ansible_host`/`ansible_user`), o que evita depender de SSH para o primeiro teste.

## O playbook

```yaml
# journal.yml
---
- name: Configurar journal persistente
  hosts: k3s_nodes
  become: true
  tasks:
    - name: Garantir que /var/log/journal exista
      ansible.builtin.file:
        path: /var/log/journal
        state: directory
        mode: "0755"

    - name: Definir Storage=persistent em journald.conf
      ansible.builtin.lineinfile:
        path: /etc/systemd/journald.conf
        regexp: "^#?Storage="
        line: "Storage=persistent"
      notify: Reiniciar systemd-journald

  handlers:
    - name: Reiniciar systemd-journald
      ansible.builtin.systemd:
        name: systemd-journald
        state: restarted
```

**Considerações:**

- `ansible.builtin.file` e `ansible.builtin.lineinfile` são módulos declarativos: cada um verifica o estado atual antes de agir e só reporta `changed` quando altera algo, o contrato de idempotência já descrito no [modelo mental do Ansible](../../../../learn/automation/ansible-model/#idempotência-como-contrato). Nenhuma tarefa aqui usa `ansible.builtin.command`/`shell`, que exigiriam uma condição explícita (`creates`, `changed_when`) para o mesmo comportamento.
- O handler só dispara quando `lineinfile` reporta `changed`; criar o diretório sozinho, sem alterar a diretiva, nunca reinicia o serviço.

## Dry-run com `--check` e `--diff`

```bash
ansible-playbook -i inventory.ini journal.yml --check --diff
```

Contra um host onde nada disso existe ainda, a saída mostra as duas tarefas como `changed`, com o diff de cada uma, sem aplicar nenhuma mudança de verdade:

```text
TASK [Garantir que /var/log/journal exista] ******************************
--- before
+++ after
@@ -1,4 +1,4 @@
 {
     "path": "/var/log/journal",
-    "state": "absent"
+    "state": "directory"
 }
changed: [node01]

TASK [Definir Storage=persistent em journald.conf] ************************
--- before: /etc/systemd/journald.conf (content)
+++ after: /etc/systemd/journald.conf (content)
@@ -0,0 +1 @@
+Storage=persistent
changed: [node01]
```

**Considerações:**

- `--check` executa o playbook em modo simulação: nenhum módulo declarativo altera o host de fato, só reporta o que mudaria.
- `--diff` mostra o conteúdo antes/depois de cada mudança, o jeito mais rápido de revisar exatamente o que um playbook vai fazer antes de rodar `--check` sem essa flag ou a execução real.

## Executar de verdade, e confirmar idempotência

```bash
# Primeira execução: aplica as mudanças de fato
ansible-playbook -i inventory.ini journal.yml
```

```text
TASK [Garantir que /var/log/journal exista] ******************************
changed: [node01]

TASK [Definir Storage=persistent em journald.conf] ************************
changed: [node01]

RUNNING HANDLER [Reiniciar systemd-journald] *******************************
changed: [node01]

PLAY RECAP ******************************************************************
node01                     : ok=4    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

Rodar o mesmo comando de novo, sem tocar em nada no host entre uma execução e outra, é a validação real de idempotência que este procedimento existe para provar:

```bash
# Segunda execução: nada deveria mudar
ansible-playbook -i inventory.ini journal.yml
```

```text
TASK [Garantir que /var/log/journal exista] ******************************
ok: [node01]

TASK [Definir Storage=persistent em journald.conf] ************************
ok: [node01]

PLAY RECAP ******************************************************************
node01                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

## Resultado esperado

`changed=0` na segunda execução, sem o handler disparar (ele não aparece na lista de tarefas executadas, porque nada notificou), e sem nenhuma linha `failed`. Esse é o sinal de que o playbook está de fato aplicando um estado declarado, não reaplicando ações às cegas a cada execução.

## Como executar novamente

Rodar o mesmo comando quantas vezes for necessário é seguro por design: a segunda execução em diante só reporta `changed` se algo no host realmente divergir do estado declarado no playbook (alguém editou `journald.conf` manualmente, por exemplo). Não há necessidade de nenhum passo de limpeza entre execuções.

## Como remover ou desfazer

Não há um "desfazer" automático: reverter significa editar o playbook para declarar o estado anterior (por exemplo, remover a tarefa de `lineinfile` e adicionar uma que restaure o valor original de `Storage`) e rodá-lo de novo, o mesmo modelo declarativo usado para aplicar a mudança em primeiro lugar.

## Troubleshooting

Se a segunda execução ainda reportar `changed` numa tarefa que deveria estar estável, o motivo mais comum é uma tarefa de `command`/`shell` sem `changed_when` explícito no meio do playbook (nenhuma existe neste exemplo, mas é a causa mais frequente em playbooks maiores); revise se alguma tarefa adicionada depois foge do padrão declarativo das duas usadas aqui. Se `ansible-playbook` falhar na conexão, confirme `ansible -i inventory.ini k3s_nodes -m ping` antes de depurar o playbook em si, isolando problema de conectividade de problema de lógica do playbook.

## Páginas relacionadas

- [Modelo mental do Ansible](../../../../learn/automation/ansible-model/): control node, inventário, módulos e o contrato de idempotência que este procedimento valida na prática.
- [Estrutura de um projeto Ansible](../../../../learn/automation/ansible-structure/): como este playbook cresceria para uma role, se o escopo aumentasse.
- [Qualidade em Ansible: ansible-lint, Molecule e execução segura](../../../../learn/automation/ansible-quality/): como automatizar a validação de idempotência feita manualmente aqui.
- [Preparar um servidor Debian](../../host/prepare-debian-server/): o roteiro completo, do qual a etapa de journal persistente usada aqui é apenas uma parte.
- [Configurar journal persistente](../../host/configure-persistent-journal/): o mesmo procedimento, feito manualmente, sem Ansible.

## Referências

- [Ansible: file module](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/file_module.html): documentação oficial do módulo usado para o diretório.
- [Ansible: lineinfile module](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/lineinfile_module.html): documentação oficial do módulo usado para a diretiva de journald.
- [Ansible: Check mode ("Dry run")](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_checkmode.html): comportamento oficial de `--check` e `--diff`.
