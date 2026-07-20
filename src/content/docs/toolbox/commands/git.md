---
title: Git
sidebar:
  order: 11
---

## Status e diff

```bash
# Resumo do que mudou
git status

# Mudanças ainda não staged
git diff

# Mudanças já staged
git diff --cached

# Comparar com outra branch
git diff main...feature
```

**Quando usar:** revisar o que mudou antes de um commit.

**Considerações:**

- `git status` mostra um resumo de arquivos modificados, novos e staged.
- `git diff` sozinho mostra as mudanças ainda não staged.
- `git diff --cached` mostra o que já foi adicionado com `git add` e entraria no próximo commit.

---

## Fazer um commit

```bash
# Commit simples
git commit -m "fix: correção de bug"

# Mensagem com título e corpo
git commit -m "Título da mudança" -m "Descrição mais detalhada aqui"

# Adicionar tudo antes de commitar (cuidado com arquivos não intencionais)
git add .
git commit -m "todos os arquivos"
```

**Quando usar:** registrar um conjunto de mudanças no histórico.

**Considerações:**

- Um padrão comum de mensagem é `tipo: descrição` (`fix`, `feat`, `docs`, entre outros), mas siga a convenção já adotada no repositório específico.
- Repetir `-m` acrescenta parágrafos ao corpo da mensagem, além do título.
- Sem `-m`, o Git abre o editor configurado para escrever a mensagem interativamente.
- `git add .` inclui todos os arquivos modificados no diretório atual; revise com `git status` antes, para não commitar algo não intencional.

---

## Ver o histórico

```bash
# Commits recentes
git log

# Uma linha por commit
git log --oneline

# Gráfico de branches
git log --graph --oneline --all

# Commits que tocaram um arquivo específico
git log -- filename
```

**Quando usar:** entender o histórico de um repositório, ou encontrar quando uma mudança específica foi introduzida.

**Considerações:**

- `--oneline` condensa cada commit em uma linha, mais fácil de escanear.
- `--graph` desenha visualmente a topologia de branches e merges.
- `--author` filtra por autor; `--since`/`--until` filtram por intervalo de tempo.

---

## Trabalhar com branches

```bash
# Listar branches
git branch

# Criar uma branch
git branch feature/my-feature

# Mudar para uma branch
git checkout feature/my-feature

# Criar e mudar em um único comando
git checkout -b feature/my-feature

# Remover uma branch já mesclada
git branch -d feature/my-feature
```

**Quando usar:** isolar trabalho em desenvolvimento, ou paralelizar múltiplas features.

**Considerações:**

- `-b` combina criação e checkout em um único comando.
- Uma branch local é independente da remota até que um `push` a sincronize.
- `git branch -d` recusa remover uma branch com commits ainda não mesclados; use `-D` (maiúsculo) apenas quando tiver certeza de que quer descartar esse trabalho.

---

## Fazer merge de branches

```bash
# Merge simples
git merge feature/my-feature

# Merge preservando um commit de merge explícito
git merge --no-ff feature/my-feature

# Abortar em caso de conflito
git merge --abort
```

**Quando usar:** integrar uma branch de feature de volta à branch principal.

**Considerações:**

- Sem `--no-ff`, o Git faz fast-forward quando possível, sem criar um commit de merge dedicado.
- Conflitos de merge exigem resolução manual antes que o merge possa ser concluído.
- `git merge --abort` só funciona enquanto o merge ainda está em andamento, antes de qualquer resolução de conflito ser commitada.

---

## Reverter um commit

```bash
# Criar um novo commit que desfaz as mudanças de outro
git revert <commit-hash>

# Reverter o último commit
git revert HEAD

# Descartar commits locais sem criar um novo commit (cuidado!)
git reset --hard HEAD~1
```

**Quando usar:** desfazer uma mudança já publicada (`revert`), ou descartar commits ainda locais (`reset`).

**Considerações:**

- `git revert` é seguro para histórico compartilhado: cria um novo commit que desfaz o anterior, sem reescrever o histórico existente.
- `git reset --hard` reescreve o histórico local e descarta mudanças permanentemente; nunca o use em uma branch que outras pessoas já baixaram, a menos que a reescrita tenha sido coordenada com a equipe.

---

## Guardar mudanças temporariamente (stash)

```bash
# Guardar mudanças não commitadas
git stash

# Listar stashes guardados
git stash list

# Recuperar e remover o último stash
git stash pop

# Recuperar um stash específico, sem removê-lo da lista
git stash apply stash@{0}
```

**Quando usar:** trocar de branch sem commitar um trabalho ainda incompleto.

**Considerações:**

- `git stash` guarda as modificações e deixa o diretório de trabalho limpo, como se as mudanças nunca tivessem existido.
- `pop` recupera o stash mais recente e o remove da lista.
- `apply` recupera um stash específico, mas o mantém na lista, útil quando o mesmo stash precisa ser aplicado em mais de um lugar.

---

## Enviar para o remoto (push)

```bash
# Push simples
git push

# Primeira vez, configurando o upstream
git push -u origin feature/my-feature

# Force push, com proteção contra sobrescrever trabalho alheio
git push --force-with-lease

# Remover uma branch no remoto
git push origin --delete feature/my-feature
```

**Quando usar:** enviar commits locais para o repositório remoto.

**Considerações:**

- `-u` configura o rastreamento (upstream) entre a branch local e a remota, necessário só na primeira vez.
- `--force-with-lease` verifica se ninguém mais atualizou a branch remota antes de sobrescrevê-la, o que o torna mais seguro que `--force` puro, mas ainda assim destrutivo se usado sem cuidado.
- Nunca faça force-push direto em `main` ou `master`; se a situação exigir reescrever essas branches, coordene com toda a equipe antes.

---

## Sincronizar com o remoto (pull)

```bash
# Fetch seguido de merge
git pull

# Só fetch, sem alterar a branch local
git fetch

# Rebase em vez de merge
git pull --rebase
```

**Quando usar:** sincronizar o repositório local com o remoto, ou atualizar antes de continuar um trabalho.

**Considerações:**

- `git pull` é equivalente a `git fetch` seguido de `git merge`.
- `git fetch` apenas baixa as referências remotas atualizadas, sem tocar na branch local atual, útil para inspecionar mudanças antes de integrá-las.
- `--rebase` reaplica os commits locais sobre o topo do histórico remoto atualizado, evitando um commit de merge extra e mantendo um histórico linear.
