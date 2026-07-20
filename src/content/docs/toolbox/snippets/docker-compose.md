---
title: Docker Compose snippets
sidebar:
  order: 2
---

## Serviço básico

```yaml
services:
  app:
    image: nginx:latest
    ports:
      - "8080:80"
    environment:
      ENV_VAR: "value"
    restart: unless-stopped
```

Um serviço com porta publicada, uma variável de ambiente e política de reinício.

---

## Com volumes

```yaml
services:
  app:
    image: myapp
    volumes:
      - ./data:/app/data          # bind mount
      - app_cache:/app/cache      # named volume

volumes:
  app_cache:
```

Combina um bind mount (um diretório do host montado direto no container) com um named volume (gerenciado pelo próprio Docker). A declaração `volumes:` que nomeia `app_cache` precisa ficar no nível raiz do arquivo, como um irmão de `services:`, não aninhada dentro do serviço; declará-la dentro do serviço por engano é um erro comum que o Compose rejeita ou interpreta incorretamente.

---

## Com rede customizada

```yaml
services:
  web:
    image: nginx
    networks:
      - backend

  api:
    image: myapi
    networks:
      - backend

networks:
  backend:
    driver: bridge
```

Serviços na mesma rede customizada conseguem se comunicar entre si pelo nome do serviço, sem precisar do IP.

---

## Com healthcheck

```yaml
services:
  api:
    image: myapi:latest
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```

O Docker marca o container como `unhealthy` depois de 3 falhas consecutivas do teste; `start_period` dá um prazo de carência inicial (aqui, 40s) antes que falhas comecem a contar, útil para aplicações com inicialização lenta.

---

## Com depends_on

```yaml
services:
  web:
    image: nginx
    depends_on:
      - api

  api:
    image: myapi
    depends_on:
      - db

  db:
    image: postgres
```

Define a ordem de início dos containers (`web` só inicia depois de `api`, que só inicia depois de `db`). Por padrão, `depends_on` garante apenas que o container dependido foi iniciado, não que ele já está pronto para aceitar conexões; para esperar por uma condição de saúde real, use a forma estendida com `condition: service_healthy`, combinada com um `healthcheck` no serviço dependido.

---

## Variáveis de ambiente

```yaml
services:
  app:
    image: myapp
    environment:
      - DB_HOST=db
      - DB_PORT=5432
      - DEBUG=${DEBUG:-false}
    env_file: .env
```

Variáveis podem ser definidas diretamente no `environment`, com um valor padrão via `${VAR:-default}`, ou carregadas de um arquivo `.env` com `env_file`. Quando as duas formas definem a mesma variável, o valor em `environment` tem precedência sobre o de `env_file`.

---

## Build local em vez de imagem pronta

```yaml
services:
  myapp:
    build:
      context: .
      dockerfile: Dockerfile
      args:
        VERSION: "1.0"
    image: myapp:latest
```

Constrói a imagem a partir de um Dockerfile local em vez de baixar uma imagem já publicada; o campo `image` opcional nomeia a imagem resultante do build, útil para reutilizá-la fora do Compose.

---

## Override para desenvolvimento

```yaml
# docker-compose.yml
services:
  app:
    image: myapp:prod
    restart: always
```

```yaml
# docker-compose.override.yml (aplicado automaticamente junto ao arquivo principal)
services:
  app:
    build: .
    restart: "no"
    volumes:
      - .:/app
```

O Docker Compose combina `docker-compose.yml` com `docker-compose.override.yml` automaticamente, quando este segundo arquivo existe no mesmo diretório, sem precisar de uma flag adicional. É uma forma comum de manter a definição de produção no arquivo principal e sobrescrever apenas o necessário para desenvolvimento local (build a partir do código-fonte, volumes de código montado, política de restart mais permissiva).
