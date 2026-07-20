---
title: Processos
sidebar:
  order: 5
---

## Listar processos

```bash
# Todos os processos, formato BSD
ps aux

# Só os processos do usuário atual
ps ux

# Árvore de processos
ps auxf
# ou
pstree
```

**Quando usar:** encontrar um processo, verificar seu estado, ou ver quanto de CPU e memória ele consome.

**Considerações:**

- `ps aux` é o comando mais usado para esse fim, com um formato fácil de ler.
- As colunas `%CPU` e `%MEM` mostram percentuais de uso dos recursos do host.
- A coluna `STAT` mostra o estado do processo: `S` para dormindo (sleep), `R` para em execução (running), `Z` para zumbi.

---

## Procurar um processo por nome

```bash
ps aux | grep nginx

# Mais direto, sem o problema do grep se listar a si mesmo
pgrep -a nginx

# Só o PID
pgrep nginx
```

**Quando usar:** encontrar o PID de uma aplicação, ou confirmar se ela está em execução.

**Considerações:**

- `ps aux | grep nginx` sempre lista o próprio processo `grep` no resultado, a menos que a expressão use uma classe de caracteres para evitar a correspondência (`grep [n]ginx`).
- `pgrep` evita esse problema por padrão e produz uma saída mais limpa.
- `-a` mostra a linha de comando completa de cada processo encontrado, não só o nome.

---

## Encerrar um processo pelo PID

```bash
# Sinal TERM, permite que o processo se encerre graciosamente
kill 1234

# Sinal KILL, encerramento imediato e forçado
kill -9 1234

# Por nome do processo
pkill -f nginx
pkill -9 -f "python my_script.py"
```

**Quando usar:** encerrar um processo travado, ou liberar uma porta ocupada.

**Considerações:**

- `TERM` (sinal 15) dá ao processo a chance de liberar recursos e encerrar de forma limpa; `KILL` (sinal 9) o encerra instantaneamente, sem chance de limpeza, e deve ser o último recurso.
- `pkill` encerra por padrão de nome, o que é menos preciso que informar um PID específico; confirme o alvo antes de usar em produção.
- `-f` faz a correspondência contra a linha de comando completa, não apenas o nome do binário.

---

## Monitorar CPU e memória em tempo real

```bash
# Interface padrão, disponível na maioria dos sistemas
top

# Interface mais amigável, requer instalação
htop

# Uma linha de resumo, atualizada a cada 2 segundos
watch -n 2 'ps aux | sort -k3,3nr | head -5'
```

**Quando usar:** diagnosticar qual processo está consumindo recursos em excesso.

**Considerações:**

- `top` já vem instalado na quase totalidade dos sistemas Linux.
- `htop` precisa ser instalado separadamente, mas oferece navegação interativa e cores mais legíveis.
- `watch` repete o comando informado no intervalo definido, útil para acompanhar uma métrica sem instalar uma ferramenta dedicada.

---

## Mudar a prioridade de um processo

```bash
# Aumentar a prioridade ao iniciar um processo (nice menor = prioridade maior; -20 é o máximo)
sudo nice -n -5 my_app

# Mudar a prioridade de um processo já em execução
sudo renice -n 10 -p 1234       # só o PID 1234
sudo renice -n 10 -u username   # todos os processos do usuário
```

**Quando usar:** priorizar aplicações críticas, ou reduzir a prioridade de tarefas de segundo plano.

**Considerações:**

- A escala de `nice` vai de -20 (prioridade mais alta) a +19 (prioridade mais baixa); valores negativos requerem privilégios de root.
- `nice` define a prioridade no momento em que o processo é iniciado; `renice` altera a de um processo que já está rodando.

---

## Processos zumbis e órfãos

```bash
# Listar zumbis (STAT = Z)
ps aux | grep ' Z '

# Listar processos marcados como defunct
ps auxf | grep defunct

# Liberar um zumbi encerrando o processo pai
sudo kill -9 <pid-do-pai>
```

**Quando usar:** limpar processos zumbis remanescentes depois da falha de uma aplicação.

**Considerações:**

- Um processo zumbi já terminou, mas seu processo pai ainda não leu o código de saída (via `wait`); ele permanece na tabela de processos até que isso aconteça.
- Um processo órfão é diferente: seu pai original morreu, e o processo é automaticamente adotado pelo `init` ou pelo `systemd`, sem virar zumbi por isso.
- O único remédio para um zumbi acumulado é fazer o processo pai ler o código de saída, ou encerrar o próprio pai (o que faz o `init` reaper coletar o zumbi).

---

## Segundo plano e primeiro plano

```bash
# Executar em segundo plano
command &

# Listar jobs em segundo plano
jobs

# Trazer um job de volta ao primeiro plano
fg %1

# Pausar um job em execução (Ctrl+Z), depois
bg %1  # continua em segundo plano
```

**Quando usar:** executar múltiplos comandos sem bloquear o terminal atual.

**Considerações:**

- `&` ao final de um comando o coloca em segundo plano automaticamente.
- `Ctrl+Z` pausa o processo em primeiro plano; `bg` o retoma em segundo plano a partir do ponto pausado.
- `fg` traz um job de volta ao primeiro plano, bloqueando o terminal novamente até ele terminar.
