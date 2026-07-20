---
title: Filesystems
sidebar:
  order: 8
---

## Verificar espaço em disco

```bash
# Resumo por filesystem
df -h

# Uso por diretório, um nível de profundidade
du -sh /*

# Os diretórios que mais ocupam espaço
du -sh /* | sort -h | tail -10
```

**Quando usar:** diagnosticar disco cheio, ou encontrar o que está consumindo o espaço.

**Considerações:**

- `df` mostra o uso no nível de filesystem (partição, ponto de montagem).
- `du` mostra o uso no nível de diretório e arquivo.
- `-h` formata os valores de forma legível (K, M, G) em vez de blocos.
- `-s` resume cada diretório em uma linha, sem listar recursivamente cada subdiretório.

---

## Verificar inodes

```bash
# Por filesystem
df -i

# Qual diretório está consumindo mais inodes
find / -xdev -printf '%h\n' 2>/dev/null | sort | uniq -c | sort -rn | head -10
```

**Quando usar:** quando o filesystem reporta espaço disponível, mas ainda assim recusa criar novos arquivos (sintoma clássico de esgotamento de inodes).

**Considerações:**

- Cada inode representa um arquivo ou diretório; mesmo um arquivo de poucos bytes consome um inode inteiro.
- Um filesystem pode ficar sem inodes disponíveis antes de ficar sem espaço em bytes, especialmente em diretórios com muitos arquivos pequenos (caches, sessões, filas em disco).

---

## Montar um filesystem

```bash
# Verificar o que já está montado
mount | grep /mnt

# Montar um compartilhamento NFS
sudo mount -t nfs server:/export /mnt/nfs

# Montar com opções específicas
sudo mount -t nfs -o rw,hard,intr server:/export /mnt/nfs

# Desmontar
sudo umount /mnt/nfs
```

**Quando usar:** adicionar armazenamento externo, montar um destino de backup pela rede, ou preparar um ambiente de desenvolvimento.

**Considerações:**

- `-t` define o tipo de filesystem (`nfs`, `cifs`, entre outros).
- `-o` define opções específicas do tipo escolhido; `rw` habilita leitura e escrita, `hard` faz o cliente NFS tentar novamente indefinidamente em caso de falha do servidor em vez de retornar erro.
- Desmonte com `umount` antes de remover fisicamente um dispositivo, para evitar corrupção de dados ainda em cache de escrita.

---

## Verificar e alterar permissões de um arquivo

```bash
# Ver permissões
ls -l file.txt
stat file.txt

# Alterar permissões, notação octal
chmod 644 file.txt    # rw- r-- r--
chmod 755 script.sh   # rwx r-x r-x

# Alterar permissões, notação simbólica
chmod u+x script.sh   # adiciona execução para o dono
chmod g-w file.txt    # remove escrita do grupo

# Recursivamente
chmod -R 755 /path/to/dir
```

**Quando usar:** corrigir permissões de um arquivo ou script, ou reforçar restrições de segurança.

**Considerações:**

- Na notação octal, cada dígito soma valores (4 = leitura, 2 = escrita, 1 = execução); o primeiro dígito se refere ao dono, o segundo ao grupo, o terceiro aos demais usuários.
- `-R` aplica a mudança recursivamente; use com cautela, já que aplicar a mesma permissão a arquivos e diretórios indiscriminadamente costuma abrir mais acesso do que o necessário (diretórios geralmente precisam do bit de execução para serem navegáveis, o que não é sempre apropriado para arquivos comuns).

---

## Alterar o dono de um arquivo

```bash
# Mudar usuário e grupo
sudo chown user:group file.txt

# Só o usuário
sudo chown user file.txt

# Só o grupo
sudo chown :group file.txt

# Recursivamente
sudo chown -R user:group /path/to/dir
```

**Quando usar:** corrigir a propriedade de um arquivo depois de uma cópia, ajustar permissões de um volume montado em container, ou reforçar segurança.

**Considerações:**

- Exige privilégios de root, ou ser o dono atual do arquivo com permissão para transferi-lo.
- `-R` aplica a mudança recursivamente a todo o conteúdo do diretório.
- O formato aceito é `usuário:grupo`; qualquer um dos dois pode ser omitido para deixar o outro inalterado.

---

## Encontrar arquivos

```bash
# Por nome
find /path -name "*.log"

# Por tamanho
find /path -size +1G   # maiores que 1GB
find /path -size -10M  # menores que 10MB

# Por idade
find /path -mtime +30  # modificado há mais de 30 dias
find /path -atime -1   # acessado há menos de 1 dia

# Executar um comando sobre os resultados
find /path -name "*.tmp" -delete
find /path -name "*.log" -exec gzip {} \;
```

**Quando usar:** limpeza de filesystem, auditoria, ou localização de logs antigos.

**Considerações:**

- `-name` é sensível a maiúsculas e minúsculas; use `-iname` para uma busca sem diferenciar caixa.
- Em `-size`, o sinal `+` significa maior que o valor informado, e `-` significa menor.
- `-delete` remove os arquivos encontrados imediatamente; teste sempre o `find` sem `-delete` primeiro para confirmar que a lista de resultados é a esperada, antes de acrescentar a remoção.
- `-exec comando {} \;` executa o comando uma vez para cada arquivo encontrado.

---

## Buscar conteúdo dentro de arquivos

```bash
# Arquivos contendo um padrão
grep -r "pattern" /path

# Sem diferenciar maiúsculas de minúsculas
grep -ri "pattern" /path

# Contar ocorrências
grep -c "pattern" file.txt

# Mostrar a linha encontrada com contexto ao redor
grep -B2 -A2 "pattern" file.txt
```

**Quando usar:** localizar uma configuração específica, depurar um comportamento, ou auditar arquivos.

**Considerações:**

- `-r` busca recursivamente em subdiretórios.
- `-i` ignora diferenças entre maiúsculas e minúsculas.
- `-B`/`-A` mostram, respectivamente, linhas antes e depois de cada ocorrência encontrada.
- `-v` inverte a busca, mostrando as linhas que não contêm o padrão.
