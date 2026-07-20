---
title: Valores aleatórios
sidebar:
  order: 1
---

## Gerar senha aleatória (printável)

```bash
openssl rand -base64 16
# Saída: abcd1234EFGH5678ijkl9012
```

**Quando usar:** configurar senhas iniciais, secrets e tokens.

**Considerações:**

- `openssl rand -base64 N` gera N bytes de aleatoriedade e os codifica em base64, que ocupa cerca de 33% mais caracteres que os bytes originais.
- Para 16 bytes de entropia, a saída tem por volta de 24 caracteres em base64.
- Alternativa sem OpenSSL: `tr -dc 'A-Za-z0-9' </dev/urandom | head -c 16`.
- Veja também [criar chave SSH](../certificates/#criar-chave-ssh).

---

## Gerar token hexadecimal

```bash
openssl rand -hex 32
# Saída: 4a5b6c7d8e9f0a1b2c3d4e5f6a7b8c9d
```

**Quando usar:** tokens de API, session IDs e qualquer valor que precise ser texto hexadecimal seguro para URLs e logs.

**Considerações:**

- `-hex` codifica em hexadecimal, usando 2 caracteres para cada byte de entropia.
- Para 32 bytes de entropia, a saída tem 64 caracteres hexadecimais.
- É mais legível que base64 em logs e arquivos de configuração, ao custo de uma string mais longa para a mesma entropia.

---

## Gerar UUID

```bash
uuidgen
# Saída: 550e8400-e29b-41d4-a716-446655440000

# Em minúsculas, quando o sistema de destino exigir
uuidgen | tr A-Z a-z
```

**Quando usar:** identificadores únicos para recursos, eventos ou IDs de cluster.

**Considerações:**

- `uuidgen`, por padrão, gera um UUID versão 4 (aleatório); a versão exata depende da implementação instalada.
- Alternativa no Linux, sem instalar nada: `cat /proc/sys/kernel/random/uuid`.

---

## Gerar número aleatório em um intervalo

```bash
# Entre 1 e 100
echo $((RANDOM % 100 + 1))

# Entre 0 e 255
echo $((RANDOM % 256))
```

**Quando usar:** delays aleatórios em scripts, ou uma semente rápida para testes.

**Considerações:**

- `$RANDOM` é uma variável específica do Bash; em `sh` puro, use `/dev/urandom` como fonte de aleatoriedade.
- `$RANDOM % N` introduz um viés leve quando `N` não divide 32768 exatamente; para intervalos grandes ou que exigem distribuição uniforme, prefira `awk 'BEGIN { srand(); print int(rand() * N) }'`.
