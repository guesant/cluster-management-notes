---
title: Troubleshooting genérico
sidebar:
  order: 7
---

## Executar o último comando novamente

```bash
# Repetir o último comando
!!

# Repetir o último comando com sudo
sudo !!

# Último comando que continha "string"
!string

# Comando específico do histórico, pelo número
!123
```

**Quando usar:** repetir um comando rapidamente, ou executá-lo de novo com privilégios elevados.

**Considerações:**

- `!!` é um atalho para `!-1` (o comando anterior).
- Expansão de histórico (`!`) pode ter efeitos inesperados dentro de scripts; desabilite com `set +H` quando necessário.
- O histórico de comandos fica salvo em `~/.bash_history`.

---

## Ver o histórico de comandos

```bash
# Últimos 20 comandos
history 20

# Limpar o histórico da sessão atual
history -c

# Executar um comando específico pelo número
!123

# Buscar por um termo no histórico
history | grep ssh
```

**Quando usar:** encontrar um comando executado anteriormente, ou revisar o que foi feito em uma sessão.

**Considerações:**

- O histórico persistente fica em `~/.bash_history`.
- `history -c` limpa apenas a memória da sessão atual, não o arquivo já salvo em disco.
- Para apagar também o arquivo: `cat /dev/null > ~/.bash_history` (isso remove permanentemente o registro; use com o mesmo cuidado que qualquer outra operação destrutiva).

---

## Redirecionar stdout e stderr

```bash
# Stdout para um arquivo
command > output.txt

# Stderr para um arquivo
command 2> errors.txt

# Ambos para o mesmo arquivo
command &> output.txt
# ou, de forma portável para shells POSIX
command > output.txt 2>&1

# Descartar toda a saída
command > /dev/null 2>&1
```

**Quando usar:** capturar logs de um comando, ou silenciar sua saída.

**Considerações:**

- O descritor `1` é o stdout (saída padrão); o `2` é o stderr (saída de erro).
- `&>` redireciona ambos de uma vez, mas é uma extensão específica do Bash, não portável para `sh` puro.
- `> file 2>&1` funciona em qualquer shell POSIX: primeiro redireciona stdout para o arquivo, depois aponta stderr para onde stdout já está apontando. A ordem importa; `2>&1 > file` não produz o mesmo resultado.

---

## Encadear comandos com pipes

```bash
# Saída de um comando como entrada do próximo
command1 | command2

# Múltiplos pipes em sequência
cat file.txt | grep pattern | sort | uniq

# Usar a mesma saída em mais de um lugar
command | tee file.txt | less
```

**Quando usar:** encadear transformações de dados, ou filtrar a saída de um comando.

**Considerações:**

- `|` conecta o stdout de um comando ao stdin do próximo.
- `tee` grava a saída em um arquivo e, ao mesmo tempo, repassa para o próximo comando do pipe.
- `xargs` converte linhas recebidas via stdin em argumentos de linha de comando, útil quando o próximo comando não lê da entrada padrão diretamente.

---

## Verificar o resultado de um comando

```bash
# Condicional
if command; then
  echo "Sucesso"
else
  echo "Falhou"
fi

# Verificar o código de saída manualmente
command
echo $?  # 0 = sucesso, qualquer outro valor = erro

# Encadeamento condicional
command1 && command2  # roda command2 só se command1 tiver sucesso
command1 || command2  # roda command2 só se command1 falhar
```

**Quando usar:** scripts, validações e tratamento de erro.

**Considerações:**

- Por convenção Unix, código de saída `0` significa sucesso; qualquer valor diferente de zero indica erro (o significado exato do código varia por comando).
- `&&` e `||` funcionam como uma forma abreviada de `if`/`else` quando a lógica é simples o suficiente para caber em uma linha.

---

## Medir o tempo de execução de um comando

```bash
# Tempo total (real, user, sys)
time command

# Com mais detalhe: memória, I/O, trocas de contexto
/usr/bin/time -v command
```

**Quando usar:** medir desempenho, ou diagnosticar lentidão.

**Considerações:**

- `time` (o builtin do shell) mostra tempo real decorrido, tempo de CPU em modo usuário e tempo de CPU em modo kernel.
- `/usr/bin/time -v` é um binário separado (não o builtin do shell) e mostra métricas adicionais, como pico de memória residente e número de trocas de contexto; pode não estar instalado por padrão em todas as distribuições.

---

## Comparar a saída de dois comandos

```bash
# Diferença entre a saída de dois comandos
diff <(command1) <(command2)

# Com comm, mais eficiente quando as entradas já são arquivos ordenados
comm -3 <(sort file1) <(sort file2)
```

**Quando usar:** comparar o estado antes e depois de uma mudança, ou a saída de dois ambientes diferentes.

**Considerações:**

- `<(...)` é process substitution, um recurso específico do Bash que trata a saída de um comando como se fosse um arquivo.
- `comm` mostra três colunas por padrão: linhas exclusivas do primeiro arquivo, exclusivas do segundo, e comuns a ambos; `-3` omite a terceira coluna (as linhas comuns), deixando só as diferenças.

---

## Executar tarefas em paralelo

```bash
# Com GNU parallel
seq 1 100 | parallel "curl https://api.example.com?id={}"

# Alternativa com xargs, sem instalar nada além do coreutils
seq 1 100 | xargs -P 4 -I {} curl "https://api.example.com?id={}"
```

**Quando usar:** acelerar tarefas independentes entre si, como testes ou downloads em lote.

**Considerações:**

- `parallel` tem uma sintaxe mais rica, mas precisa ser instalado separadamente na maioria das distribuições.
- `xargs -P N` limita a execução a no máximo N processos simultâneos, e já vem disponível em qualquer sistema com coreutils.
- Ao paralelizar chamadas contra uma API externa, respeite os limites de taxa do servidor; um paralelismo alto pode ser interpretado como abuso e resultar em bloqueio.
