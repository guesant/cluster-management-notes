---
title: Containers (Docker)
sidebar:
  order: 10
---

## Listar containers

```bash
# Só os que estão rodando
docker ps

# Todos, inclusive parados
docker ps -a

# Os últimos N criados
docker ps -n 5

# Com o tamanho de cada um
docker ps -s
```

**Quando usar:** confirmar que um container está rodando, ou encontrar um que parou inesperadamente.

**Considerações:**

- `docker ps` sozinho mostra apenas containers em execução.
- `-a` inclui também os que já saíram (`Exited`).
- A coluna `STATUS` indica o estado: `Up`, `Exited`, `Paused`, entre outros.

---

## Ver logs de um container

```bash
# Logs recentes
docker logs <container>

# Últimas 100 linhas
docker logs --tail 100 <container>

# Acompanhar em tempo real
docker logs -f <container>

# Com timestamp em cada linha
docker logs -t <container>
```

**Quando usar:** depurar uma aplicação, ou investigar um erro.

**Considerações:**

- `-f` acompanha os logs em tempo real, como `tail -f`.
- `-t` acrescenta o timestamp de cada linha, útil para correlacionar com outros eventos.
- `--tail N` limita a saída às últimas N linhas, evitando um despejo enorme em containers com muito log acumulado.

---

## Executar um comando dentro de um container

```bash
# Shell interativo
docker exec -it <container> /bin/bash

# Comando único
docker exec <container> env

# Como um usuário específico
docker exec -u www-data <container> whoami
```

**Quando usar:** depurar o estado interno de um container, ou inspecionar seu ambiente.

**Considerações:**

- `-it` combina modo interativo e alocação de TTY, necessário para um shell utilizável.
- O container precisa já estar em execução; `exec` não funciona em um container parado (para isso, veja `docker start`).
- `/bin/sh` é mais portável que `/bin/bash`: imagens minimalistas como Alpine não incluem Bash por padrão.

---

## Inspecionar um container

```bash
# Detalhes completos, em JSON
docker inspect <container>

# Só o IP
docker inspect --format='{{.NetworkSettings.IPAddress}}' <container>

# Variáveis de ambiente
docker inspect --format='{{json .Config.Env}}' <container> | jq .
```

**Quando usar:** descobrir configuração, rede ou volumes montados de um container.

**Considerações:**

- `docker inspect` retorna a configuração completa do container em JSON.
- `--format` filtra o resultado para um campo específico, usando a sintaxe de templates do Go.
- Útil em automação, onde extrair um único valor é mais prático que processar o JSON inteiro.

---

## Listar imagens

```bash
# Todas as imagens locais
docker images

# Incluindo os digests
docker images --digests

# Só as imagens dangling (sem tag)
docker images -f dangling=true
```

**Quando usar:** confirmar que uma imagem está disponível localmente, ou identificar candidatas a limpeza.

**Considerações:**

- A coluna `REPOSITORY:TAG` identifica o nome completo da imagem.
- `SIZE` mostra o tamanho descompactado da imagem, não o tamanho comprimido transferido no pull.
- Imagens dangling são camadas intermediárias que ficaram sem tag, geralmente resultado de builds anteriores sobrescritos.

---

## Remover containers e imagens

```bash
# Parar e depois remover
docker stop <container>
docker rm <container>

# Ou em um único comando, forçando a parada
docker rm -f <container>

# Remover uma imagem
docker rmi <image>

# Remover todas as imagens dangling
docker image prune
```

**Quando usar:** limpeza de espaço em disco, ou remoção de containers que falharam.

**Considerações:**

- `-f` força a remoção mesmo que o container esteja rodando, encerrando-o abruptamente no processo; confirme que não há trabalho em andamento antes de usar.
- `docker image prune` remove apenas imagens dangling; para remover também imagens não usadas por nenhum container (mas ainda tagueadas), use `docker image prune -a`, com mais cautela, já que isso pode remover imagens que você pretendia reutilizar.
- `docker container prune` remove todos os containers parados de uma vez.

---

## Build de uma imagem

```bash
# Build simples
docker build -t myapp:1.0 .

# Com um Dockerfile alternativo
docker build -f Dockerfile.dev -t myapp:dev .

# Passando argumentos de build
docker build --build-arg VERSION=1.0 -t myapp:1.0 .
```

**Quando usar:** criar uma imagem customizada a partir de um Dockerfile.

**Considerações:**

- O `.` final define o contexto de build (o diretório enviado ao daemon do Docker), não necessariamente onde está o Dockerfile.
- `-t` define a tag da imagem resultante.
- `-f` aponta para um Dockerfile diferente do padrão (`Dockerfile` no contexto).
- As camadas de build são cacheadas por instrução; ordenar o Dockerfile para copiar dependências antes do código-fonte aproveita melhor esse cache entre builds sucessivos.

---

## Enviar uma imagem para um registry

```bash
# Login (uma vez por sessão)
docker login

# Marcar a imagem com o nome do registry
docker tag myapp:1.0 myregistry/myapp:1.0

# Enviar
docker push myregistry/myapp:1.0

# Logout
docker logout
```

**Quando usar:** publicar uma imagem em um registry (Docker Hub, ECR, ou outro).

**Considerações:**

- `docker login` salva as credenciais em `~/.docker/config.json`; por padrão, em texto não cifrado, a menos que um credential helper esteja configurado.
- A tag precisa incluir o endereço do registry de destino, exceto quando o alvo for o Docker Hub.
- Prefira tokens de acesso com escopo limitado em vez da senha da conta, especialmente em pipelines de CI.
