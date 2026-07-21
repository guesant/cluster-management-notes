---
title: Logs
sidebar:
  order: 9.5
---

## Ver o journal completo do sistema

```bash
journalctl
# Do mais antigo para o mais recente, com paginação

journalctl -r
# Do mais recente para o mais antigo

journalctl -f
# Acompanha em tempo real, todas as unidades e o kernel
```

**Quando usar:** ter uma visão geral do que está acontecendo no host, antes de já saber qual serviço específico investigar.

**Considerações:**

- Sem `-u`, `journalctl` mistura o log de todas as unidades e do kernel na mesma linha do tempo; para filtrar por um serviço específico, veja [ver logs de um serviço](../systemd/#ver-logs-de-um-serviço).
- `-r` inverte a ordem, útil quando o evento mais relevante é o mais recente.
- A saída passa pelo paginador configurado (`less` por padrão); use `--no-pager` para redirecionar a outro comando ou arquivo, por exemplo `journalctl --no-pager > log.txt`.

---

## Consultar boots anteriores

```bash
journalctl --list-boots
# Lista cada boot com índice, ID e intervalo de tempo

journalctl -b -1
# Logs do boot imediatamente anterior ao atual

journalctl -b -1 -p err
# Só entradas de erro ou mais graves, do boot anterior
```

**Quando usar:** investigar uma falha que aconteceu antes de uma reinicialização (travamento, kernel panic, corte de energia), quando o log do boot atual não tem o contexto do que causou o problema.

**Considerações:**

- O índice de boot é relativo ao atual (`0`); `-1` é sempre o boot imediatamente anterior, `-2` o anterior a esse, independentemente de quantos boots existem no journal.
- A disponibilidade de boots antigos depende da retenção configurada em `journald`; se o journal não for persistente entre reinicializações, `--list-boots` mostra só o boot atual. Ver [configurar journal persistente](../../../guides/tasks/host/configure-persistent-journal/).

---

## Filtrar por prioridade

```bash
# Só erros e níveis mais graves (crit, alert, emerg)
journalctl -p err

# Um intervalo de prioridades: de warning até emerg
journalctl -p warning..emerg
```

**Quando usar:** reduzir um volume grande de log ao que provavelmente importa, quando o sintoma é genérico ("algo deu errado") e não há ainda uma unidade específica para filtrar.

**Considerações:**

- As prioridades seguem a escala do `syslog`, da mais grave para a mais branda: `emerg`, `alert`, `crit`, `err`, `warning`, `notice`, `info`, `debug`.
- `-p <nível>` sozinho inclui o nível informado e todos os mais graves, não só aquele nível exato; para um nível isolado, combine com `..` no mesmo valor (`-p err..err`).
- Filtrar por prioridade depende da aplicação classificar corretamente suas mensagens; um serviço que grava tudo como `info` não aparece em um filtro por `err`, mesmo relatando uma falha real no texto da mensagem.

---

## Ler o log do kernel (dmesg)

```bash
dmesg -T
# Com timestamp legível (sem -T, mostra segundos desde o boot)

dmesg -w
# Acompanha novas mensagens em tempo real, como tail -f

dmesg --level=err,warn
# Só mensagens de erro e aviso
```

**Quando usar:** investigar eventos que o kernel reporta diretamente e não passam por um serviço específico: dispositivos de hardware, módulos, OOM killer, erros de filesystem no nível de bloco.

**Considerações:**

- `dmesg` lê o buffer circular de mensagens do kernel; em um host com muito tempo de atividade e muitas mensagens, as entradas mais antigas já podem ter sido descartadas do buffer, mesmo sem indicação explícita disso.
- O mesmo conteúdo também aparece em `journalctl -k`, que soma a vantagem de herdar os filtros de `journalctl` (por prioridade, por boot, por intervalo de tempo); prefira `journalctl -k` quando precisar combinar com esses filtros.
- Sem `-T`, os timestamps são segundos desde o boot, não hora do relógio; isso é fácil de interpretar errado ao comparar com outro log que usa hora absoluta.

---

## Relacionado

- [Ver logs de um serviço](../systemd/#ver-logs-de-um-serviço), para `journalctl -u` filtrado por unidade.
- [Ver logs de um container](../containers/#ver-logs-de-um-container), para `docker logs`.
- [Ver logs de um Pod](../kubernetes/#ver-logs-de-um-pod), para `kubectl logs`.
- [Configurar journal persistente](../../../guides/tasks/host/configure-persistent-journal/), para reter logs entre reinicializações além do padrão do host.
