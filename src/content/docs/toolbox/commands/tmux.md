---
title: tmux
sidebar:
  order: 12
---

tmux organiza o terminal em três níveis: uma **sessão** agrupa uma ou mais **janelas**, e cada janela pode dividir seu espaço em um ou mais **painéis**. Uma sessão continua rodando no servidor mesmo depois que o terminal que a criou fecha ou a conexão SSH cai; reconectar (`attach`) recupera exatamente o estado onde a sessão foi deixada, o motivo pelo qual tmux é a ferramenta certa para qualquer trabalho de longa duração num host remoto.

## Criar uma sessão nomeada

```bash
tmux new -s deploy
```

**Quando usar:** iniciar um trabalho que deve sobreviver à desconexão, com um nome que identifica o propósito da sessão em vez de um número genérico.

**Considerações:**

- Nomear a sessão (`-s nome`) facilita reconectar depois, especialmente com várias sessões abertas ao mesmo tempo; sem `-s`, tmux atribui um número sequencial difícil de lembrar.
- Uma sessão nomeada com um propósito claro (`deploy`, `logs-prod`) também evita reconectar acidentalmente à sessão errada e interromper outro trabalho em andamento.

---

## Sobreviver a uma queda de conexão SSH

```bash
# Dentro da sessão SSH, antes de iniciar um comando longo
tmux new -s manutencao

# Se a conexão cair, reconecte via SSH e recupere a sessão
tmux attach -t manutencao
```

**Quando usar:** este é o caso de uso central de tmux para operação remota de cluster: qualquer comando de longa duração rodado diretamente numa sessão SSH sem terminal multiplexado morre junto com a conexão se o link cair (rede instável, laptop suspenso, VPN reconectando); dentro de uma sessão tmux, o comando continua rodando no servidor independente do estado da conexão SSH.

**Considerações:**

- Iniciar a sessão tmux **antes** de começar o trabalho é o que garante a sobrevivência; anexar a uma sessão tmux depois que um comando já está rodando fora dela não recupera esse comando específico.
- `tmux attach -t nome` falha com um erro claro se a sessão já não existir (por exemplo, se o host reiniciou), o que distingue "a sessão foi encerrada" de "a conexão caiu, mas a sessão continua lá".

---

## Desanexar sem encerrar (detach)

```bash
# Dentro de uma sessão tmux
Ctrl+b d
```

**Quando usar:** sair de uma sessão deliberadamente, preservando o trabalho em andamento, sem fechar o terminal físico ou a conexão SSH via encerramento normal.

**Considerações:**

- `Ctrl+b` é o prefixo padrão de comando do tmux; todo atalho começa soltando `Ctrl+b` e pressionando a tecla seguinte, não uma combinação simultânea de três teclas.
- Desanexar (`d`) é diferente de encerrar a sessão: a sessão e todos os processos dentro dela continuam rodando no servidor, prontos para `attach` mais tarde.

---

## Listar sessões ativas

```bash
tmux ls
```

**Quando usar:** confirmar quais sessões existem no servidor antes de decidir a qual anexar, ou verificar se uma sessão esperada ainda está viva.

**Considerações:**

- A saída lista nome, número de janelas e se a sessão está atualmente anexada a algum terminal (`attached`) ou não.
- Rodar `tmux ls` logo após reconectar via SSH é uma forma rápida de confirmar se um trabalho de longa duração iniciado antes ainda está em andamento.

---

## Janelas e painéis

```bash
# Nova janela dentro da sessão atual
Ctrl+b c

# Alternar entre janelas
Ctrl+b <número da janela>
Ctrl+b n   # próxima janela
Ctrl+b p   # janela anterior

# Dividir o painel atual
Ctrl+b %   # divisão vertical (lado a lado)
Ctrl+b "   # divisão horizontal (empilhado)

# Navegar entre painéis
Ctrl+b <seta do teclado>
```

**Quando usar:** organizar múltiplos comandos relacionados dentro da mesma sessão (por exemplo, um painel rodando `kubectl logs -f`, outro com o shell livre para outros comandos), em vez de abrir sessões separadas para cada um.

**Considerações:**

- Janelas são melhores para tarefas não relacionadas dentro da mesma sessão (cada janela ocupa a tela inteira); painéis são melhores para tarefas relacionadas que precisam ficar visíveis ao mesmo tempo.
- Fechar um painel ou uma janela (`exit` ou `Ctrl+d` no shell dentro dele) não afeta os demais; a sessão só termina quando o último painel da última janela fecha.

---

## Copy mode: rolar e copiar texto

```bash
# Entrar em copy mode
Ctrl+b [

# Navegar com as setas ou vi-style (hjkl)
# Marcar início da seleção: Espaço
# Copiar seleção: Enter
# Sair sem copiar: q

# Colar o que foi copiado
Ctrl+b ]
```

**Quando usar:** rolar para cima e ler saída de comando que já passou do topo da tela visível, ou copiar um trecho de texto (um hash de commit, um endereço IP) para colar em outro lugar dentro do próprio tmux.

**Considerações:**

- O buffer de rolagem normal do terminal (scroll do mouse, `Shift+PageUp`) não funciona da mesma forma dentro de tmux, porque tmux controla o próprio buffer de tela; copy mode é o mecanismo nativo para isso.
- Copiar em copy mode usa o buffer interno do próprio tmux, separado da área de transferência do sistema operacional; colar fora do tmux (em outro programa) normalmente exige configuração adicional de integração com o clipboard do sistema, fora do escopo desta recipe.

---

## tmux vs. screen: os mesmos comandos, prefixo diferente

**screen** (GNU Screen) resolve o mesmo problema central que motiva esta página, sessão que sobrevive à queda de uma conexão SSH, e é mais antigo que tmux (final dos anos 1980, contra os anos 2000 do tmux). Os comandos equivalentes às recipes acima:

```bash
# Sessão nomeada
screen -S deploy

# Desanexar (prefixo Ctrl+a, não Ctrl+b)
Ctrl+a d

# Reconectar
screen -r deploy

# Listar sessões
screen -ls
```

Nenhum dos dois é estritamente superior; a escolha depende do que o operador prioriza:

| Critério | screen | tmux |
| --- | --- | --- |
| Divisão de painéis | Suporte tardio e mais limitado (`Ctrl+a S`/`\|`) | Nativo desde o início, split vertical/horizontal direto (`%`/`"`) |
| Configuração/scriptability | Sintaxe mais antiga, menos expressiva | `tmux.conf` e comandos como `send-keys`/`new-session -d` facilitam automação |
| Desenvolvimento ativo | Essencialmente em modo de manutenção | Recebe features e correções continuamente |
| Presença por padrão | Mais onipresente em sistemas Unix-like minimalistas antigos | Precisa de instalação explícita com mais frequência, mas já é comum na maioria das distros atuais |
| Arquitetura client-server | Mais simples, menos separação | Servidor e clientes bem separados, facilita múltiplos terminais na mesma sessão |

**Quando escolher screen em vez de tmux:** um host minimalista onde `screen` já está instalado e `tmux` não pode ser adicionado, ou uma necessidade pontual de detach/reattach simples, sem painéis. Fora desses casos, `tmux` é a escolha mais capaz para o mesmo trabalho, e por isso é o multiplexador padrão usado no restante desta página.

## Relacionado

- [Comandos de systemd](../systemd/): outra ferramenta para processos de longa duração, mas como serviço gerenciado pelo init, não como sessão de terminal interativa.
