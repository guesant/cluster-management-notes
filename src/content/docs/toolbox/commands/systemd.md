---
title: Systemd
sidebar:
  order: 9
---

## Gerenciar serviços

```bash
# Iniciar, parar, reiniciar
sudo systemctl start nginx
sudo systemctl stop nginx
sudo systemctl restart nginx

# Habilitar ou desabilitar no boot
sudo systemctl enable nginx
sudo systemctl disable nginx

# Status
sudo systemctl status nginx
```

**Quando usar:** ligar ou desligar aplicações, configurar início automático, ou um diagnóstico rápido de saúde.

**Considerações:**

- `start` inicia o serviço imediatamente, sem alterar seu comportamento no próximo boot.
- `enable` adiciona o serviço ao início automático, sem iniciá-lo agora; combine com `start` quando quiser as duas coisas de uma vez.
- `status` mostra o PID, o estado atual e as últimas linhas de log do serviço.

---

## Ver logs de um serviço

```bash
# Logs recentes
journalctl -u nginx

# Últimas 50 linhas
journalctl -u nginx -n 50

# Acompanhar em tempo real
journalctl -u nginx -f

# Desde o último boot
journalctl -u nginx -b

# Entre dois timestamps
journalctl -u nginx --since "2026-07-19 10:00:00" --until "2026-07-19 11:00:00"
```

**Quando usar:** depurar um serviço, ou investigar um erro de inicialização.

**Considerações:**

- `journalctl` é o sistema de log centralizado do systemd; a maioria dos serviços gerenciados por ele grava logs ali, mesmo sem um arquivo de log dedicado.
- `-u` filtra por unidade (o nome do serviço).
- `-f` acompanha os logs em tempo real, como `tail -f`.
- `-b` restringe a saída aos logs desde o último boot, útil para descartar ruído de execuções anteriores.

---

## Recarregar a configuração de um serviço

```bash
# Recarrega a configuração sem reiniciar o processo
sudo systemctl reload nginx

# Recarrega o próprio systemd, necessário depois de editar um arquivo .service
sudo systemctl daemon-reload

# Confirmar que a unidade está saudável após a mudança
sudo systemctl status nginx
```

**Quando usar:** aplicar mudanças de configuração sem indisponibilidade, quando o serviço suportar isso.

**Considerações:**

- `reload` pede ao próprio processo que releia sua configuração, mantendo as conexões já abertas; nem todo serviço implementa esse comportamento (verifique a documentação do serviço específico).
- `daemon-reload` é obrigatório sempre que um arquivo `.service` for editado, mesmo que o serviço em si não tenha mudado.
- `restart` encerra o processo e inicia um novo, causando uma janela de indisponibilidade que `reload` evita.

---

## Timers (agendamento)

```bash
# Listar timers ativos
systemctl list-timers

# Ver um timer específico
systemctl status systemd-tmpfiles-clean.timer

# Disparar a unidade associada agora, para testar
sudo systemctl start systemd-tmpfiles-clean.service
```

**Quando usar:** agendar tarefas recorrentes (backups, limpeza), como alternativa ao cron.

**Considerações:**

- Timers do systemd suportam recursos que o cron tradicional não tem nativamente, como atraso aleatório de início (`RandomizedDelaySec`) e execução retroativa de tarefas perdidas (`Persistent=true`).
- Os logs da execução de um timer vão para o `journalctl`, junto com os da unidade de serviço associada.

---

## Criar um serviço customizado

```bash
sudo nano /etc/systemd/system/myapp.service
```

Conteúdo mínimo do arquivo:

```ini
[Unit]
Description=My Application
After=network.target

[Service]
Type=simple
User=myuser
WorkingDirectory=/opt/myapp
ExecStart=/usr/bin/python3 /opt/myapp/main.py
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

Depois de criado:

```bash
sudo systemctl daemon-reload
sudo systemctl enable myapp.service
sudo systemctl start myapp.service
```

**Quando usar:** rodar uma aplicação customizada como um serviço gerenciado pelo systemd.

**Considerações:**

- `[Unit]` contém metadados e dependências, como `After`, que garante que o serviço só inicie depois que a rede estiver disponível.
- `[Service]` define como o processo é executado: usuário, diretório de trabalho e política de reinício.
- `[Install]` define o comportamento de início automático e a qual target o serviço pertence.
- `Type=simple` (o padrão) considera o serviço iniciado assim que o processo do `ExecStart` é criado; `Type=forking` é necessário para daemons tradicionais que fazem fork de si mesmos e encerram o processo original.

---

## Targets e dependências

```bash
# Ver o target atual (equivalente ao antigo runlevel)
systemctl get-default

# Mudar para outro target
sudo systemctl isolate multi-user.target  # só linha de comando
sudo systemctl isolate graphical.target   # com interface gráfica

# Listar todos os targets disponíveis
systemctl list-units --type=target

# Dependências de uma unidade específica
systemctl list-dependencies nginx
```

**Quando usar:** inicializar o sistema em um modo específico, ou entender a ordem de boot.

**Considerações:**

- `multi-user.target` é o modo típico de servidor, sem interface gráfica.
- `graphical.target` inclui o ambiente desktop, quando instalado.
- `rescue.target` é o modo de emergência com o mínimo de serviços ativos, útil para recuperação.
