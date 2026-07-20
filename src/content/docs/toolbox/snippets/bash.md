---
title: Bash snippets
sidebar:
  order: 1
---

## Modo estrito e tratamento de erro

```bash
set -euo pipefail
trap 'echo "Error on line $LINENO"' ERR
```

Roda o script em modo estrito: encerra ao primeiro erro (`-e`), trata variáveis não definidas como erro (`-u`) e propaga falhas dentro de um pipe (`-o pipefail`, sem isso, `comando_que_falha | grep x` só reporta o código de saída do `grep`). O `trap` imprime a linha exata onde o erro ocorreu, útil para localizar a falha em um script maior.

---

## Validar que uma variável está definida

```bash
: "${VAR:?VAR não definido}"

# Ou usando um valor padrão em vez de falhar
: "${VAR:=${DEFAULT}}"
```

A primeira forma garante que `VAR` está definida e não vazia; se não estiver, o script falha imediatamente com a mensagem informada, em vez de continuar com um valor vazio silenciosamente. A segunda forma atribui um valor padrão a `VAR` quando ela estiver vazia, sem interromper a execução.

---

## Loop com nova tentativa (retry)

```bash
for i in {1..5}; do
  if comando; then
    break
  fi
  echo "Tentativa $i falhou, tentando novamente..."
  sleep $((2 ** i))  # backoff exponencial
done
```

Tenta executar `comando` até 5 vezes, aumentando o intervalo entre tentativas de forma exponencial (2s, 4s, 8s, 16s, 32s). Útil para operações que podem falhar por condições transitórias, como uma chamada de rede.

---

## Limpeza garantida com trap

```bash
cleanup() {
  rm -rf "$tmpdir"
}
tmpdir=$(mktemp -d)
trap cleanup EXIT
```

Garante que `tmpdir` é removido ao final da execução do script, tanto em uma saída normal quanto em uma saída por erro, já que o `trap EXIT` dispara em ambos os casos.

---

## Processamento em paralelo

```bash
for file in *.txt; do
  process_file "$file" &
done
wait  # aguarda todos os processos em segundo plano terminarem
```

Processa múltiplos arquivos em paralelo, um processo em segundo plano por arquivo, e só continua depois que todos terminarem. Não limita o número de processos simultâneos; para um número grande de arquivos, prefira `xargs -P N` (veja [executar tarefas em paralelo](../../commands/troubleshooting/#executar-tarefas-em-paralelo)) para controlar o paralelismo.

---

## Função com validação de dependência

```bash
require_command() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Erro: comando '$1' não encontrado" >&2
    return 1
  }
}

require_command docker
```

Confirma que um comando externo existe no `PATH` antes de o script depender dele, produzindo um erro claro em vez de uma falha obscura mais adiante na execução.

---

## Manipulação de string sem comandos externos

```bash
# Remover um prefixo
"${VAR#prefix}"

# Remover um sufixo
"${VAR%suffix}"

# Substituir um trecho
"${VAR/old/new}"

# Converter para maiúsculas (Bash 4 ou superior)
"${VAR^^}"
```

Essas expansões de parâmetro do próprio Bash evitam abrir um subprocesso (`sed`, `tr`) só para uma manipulação simples de string, o que é mais rápido e evita depender de ferramentas externas nem sempre disponíveis.

---

## Saída colorida no terminal

```bash
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}OK${NC}"
echo -e "${RED}Erro${NC}"
```

Adiciona cor à saída do terminal para destacar sucesso ou erro. `-e` é necessário para o `echo` interpretar as sequências de escape; scripts rodando em um pipeline de CI sem terminal interativo às vezes exibem os códigos de escape como texto literal em vez de cor, então trate isso como um recurso cosmético, não como parte da lógica do script.

---

## Execução condicional

```bash
# Só executa se a saída do comando não for vazia
output=$(comando)
[[ -n "$output" ]] && echo "Resultado: $output"

# Só executa se o arquivo foi modificado há menos de 1 hora
[[ $(find file -mmin -60) ]] && echo "Recente"
```

Atalhos comuns para evitar um `if` completo quando a condição é simples o suficiente para caber em uma linha.
