---
title: Systemd snippets
sidebar:
  order: 4
---

Fragmentos de units de serviço e timer para copiar dentro de um arquivo `.service`/`.timer` já em edição. Para o procedimento completo de criar, instalar e ativar uma unit (incluindo `systemctl daemon-reload`, `enable` e `start`), veja [criar um serviço customizado](../../commands/systemd/#criar-um-serviço-customizado) e [timers](../../commands/systemd/#timers-agendamento) no cookbook de comandos; esta página não repete esse procedimento, só os fragmentos.

## Serviço oneshot

```ini
[Unit]
Description=Minha tarefa
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/minha-tarefa.sh
```

`Type=oneshot` é para uma tarefa que executa e termina, diferente do `Type=simple` (já coberto no cookbook de comandos) usado por processos de longa duração. É o tipo de serviço que um timer dispara.

---

## Serviço de longa duração com limites de recursos

```ini
[Unit]
Description=Minha aplicação
After=network.target

[Service]
Type=simple
User=myuser
ExecStart=/usr/bin/myapp
Restart=on-failure
RestartSec=5
MemoryMax=512M
CPUQuota=50%

[Install]
WantedBy=multi-user.target
```

Acrescenta ao exemplo mínimo do cookbook um teto de memória e CPU aplicado via cgroups (`MemoryMax`, `CPUQuota`) e um intervalo antes de tentar reiniciar (`RestartSec`), para não entrar em um loop de reinícios imediatos depois de uma falha recorrente.

---

## Timer diário

```ini
[Unit]
Description=Agenda minha-tarefa diariamente

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
```

Um arquivo `minha-tarefa.timer` como este aciona a unidade `minha-tarefa.service` de mesmo nome. `OnCalendar=daily` equivale a rodar à meia-noite; `Persistent=true` executa a tarefa perdida assim que o sistema volta a ligar, caso o horário programado tenha passado com a máquina desligada, o que `OnCalendar` sozinho não garante.

---

## Timer relativo ao boot ou à última execução

```ini
[Timer]
OnBootSec=15min
OnUnitActiveSec=1h
RandomizedDelaySec=300
```

`OnBootSec` dispara a primeira execução um tempo fixo depois do boot, em vez de em um horário fixo do relógio. `OnUnitActiveSec` repete a partir do fim da execução anterior, não de um horário de calendário; combine os dois quando o intervalo entre execuções importa mais que o horário exato. `RandomizedDelaySec` espalha a execução dentro de uma janela aleatória (aqui, até 300 segundos), útil para evitar que várias instâncias do mesmo timer, em hosts diferentes, disparem todas no mesmo segundo.

---

## Drop-in: sobrescrever parte de uma unit sem editar o arquivo original

```bash
sudo systemctl edit myapp.service
```

```ini
[Service]
Environment=DEBUG=true
MemoryMax=1G
```

`systemctl edit` abre um editor e grava o conteúdo em `/etc/systemd/system/myapp.service.d/override.conf`, sem alterar a unit original (por exemplo, uma instalada por um pacote). Os campos declarados no drop-in substituem os equivalentes da unit base; os demais continuam herdados dela normalmente.
