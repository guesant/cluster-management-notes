---
title: Certificados
sidebar:
  order: 2
---

## Criar chave SSH

```bash
ssh-keygen -t ed25519 -C "seu-email@example.com" -f ~/.ssh/id_ed25519 -N ""
```

**Quando usar:** configurar autenticação SSH ou uma deployment key.

**Considerações:**

- `-t ed25519`: tipo de chave moderno, mais seguro e mais compacto que RSA para o mesmo nível de segurança.
- `-N ""`: gera a chave sem passphrase; conveniente para automação, mas reduz a proteção se o arquivo da chave privada vazar. Avalie o risco antes de usar em produção.
- Sem `-f`, o comando pergunta interativamente o caminho do arquivo.
- Ajuste as permissões da chave privada depois de criada: `chmod 600 ~/.ssh/id_ed25519`.

---

## Inspecionar certificado X.509

```bash
openssl x509 -in cert.pem -text -noout
# Mostra CN, SAN, validade e emissor
```

**Quando usar:** verificar domínios alternativos (SAN), data de expiração ou emissor de um certificado.

**Considerações:**

- `-noout` evita reimprimir o certificado no formato PEM original.
- Sem `-text`, o comando mostra apenas fingerprint e número de série.
- Para certificados no formato DER (binário), adicione `-inform der`: `openssl x509 -inform der -in cert.der -text -noout`.

---

## Verificar expiração de certificado

```bash
openssl x509 -in cert.pem -noout -dates
# Retorna notBefore=... e notAfter=...

# Só a data de expiração, mais fácil de processar
openssl x509 -in cert.pem -noout -enddate | cut -d= -f2
```

**Quando usar:** auditoria de certificados próximos do vencimento, ou automação de alertas de renovação.

**Considerações:**

- `-dates` mostra tanto `notBefore` quanto `notAfter` na mesma saída.
- Para comparar com a data atual em um script: `date -d "$(openssl x509 -in cert.pem -noout -enddate | cut -d= -f2)" +%s`.

---

## Converter certificado de PEM para DER

```bash
openssl x509 -in cert.pem -outform der -out cert.der
```

**Quando usar:** alguns sistemas (Windows, Android) esperam certificados no formato DER binário em vez de PEM texto.

**Considerações:**

- PEM é texto ASCII codificado em base64, portável e fácil de inspecionar.
- DER é binário, mais compacto e menos legível diretamente.
- Para reverter a conversão: `openssl x509 -inform der -in cert.der -out cert.pem`.

---

## Gerar uma CSR (Certificate Signing Request)

```bash
openssl req -new -key private.pem -out request.csr \
  -subj "/C=BR/ST=SP/L=São Paulo/O=Empresa/CN=example.com"
```

**Quando usar:** solicitar um certificado assinado por uma autoridade certificadora (Let's Encrypt, DigiCert, entre outras).

**Considerações:**

- O comando usa uma chave privada já existente (`private.pem`); gere-a antes com `openssl genpkey` ou equivalente.
- `-subj` evita o prompt interativo, útil em automação.
- Depois de gerada, a CSR (`.csr`) é enviada à autoridade certificadora; ela nunca deve conter a chave privada.

---

## Verificar o certificado de um servidor remoto

```bash
openssl s_client -connect example.com:443 -showcerts < /dev/null | openssl x509 -text -noout
```

**Quando usar:** auditar o certificado de um serviço remoto sem precisar baixar o arquivo manualmente.

**Considerações:**

- O comando conecta ao servidor, recebe a cadeia de certificados apresentada durante o handshake TLS e mostra os detalhes do primeiro certificado da cadeia.
- Útil para verificações rápidas de expiração antes de confiar em um alerta de monitoramento externo.
