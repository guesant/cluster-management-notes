---
title: Criptografia
sidebar:
  order: 2.5
---

## Codificar não é criptografar (base64)

```bash
echo -n "texto original" | base64
# Saída: dGV4dG8gb3JpZ2luYWw=

echo -n "dGV4dG8gb3JpZ2luYWw=" | base64 -d
# Saída: texto original
```

**Quando usar:** transportar dados binários em canais que só aceitam texto, como JSON, YAML, variáveis de ambiente ou o campo `data` de um `Secret` do Kubernetes. Nunca para proteger um segredo.

**Considerações:**

- Base64 é uma codificação reversível e sem chave: qualquer pessoa com acesso ao valor codificado recupera o original com um único comando, sem senha nem chave privada envolvida.
- Um `Secret` do Kubernetes armazenado como base64 não está criptografado; é só a codificação exigida pelo formato do recurso, porque o campo `data` do YAML precisa ser texto. A proteção real de um `Secret` vem da criptografia em repouso do `etcd` e do controle de acesso via RBAC, não do base64 em si; veja [criptografia vs. secret store](../../../learn/secrets-management/encryption-vs-secret-store/) para essa distinção.
- Quando o objetivo é de fato proteger o conteúdo, use uma das recipes desta página: hash para verificar integridade, GPG ou `age` para cifrar com chave ou senha.

---

## Gerar hash de um arquivo

```bash
sha256sum arquivo.tar.gz
# Saída: <hash em hex>  arquivo.tar.gz

# Outros algoritmos disponíveis
sha1sum arquivo.tar.gz
md5sum arquivo.tar.gz
```

**Quando usar:** obter a impressão digital de um arquivo para comparação, integridade ou identificação de duplicatas.

**Considerações:**

- `sha256sum` é o padrão recomendado atualmente; `md5sum` e `sha1sum` ainda aparecem em checksums publicados por projetos antigos, mas não devem ser usados para fins de segurança, pois ambos têm colisões conhecidas.
- O hash depende só do conteúdo do arquivo, não do nome nem dos metadados (permissões, timestamps).

---

## Verificar checksum de um arquivo baixado

```bash
sha256sum -c arquivo.sha256
# arquivo.tar.gz: OK

# Quando o checksum vem solto, sem arquivo .sha256
echo "<hash-esperado>  arquivo.tar.gz" | sha256sum -c -
```

**Quando usar:** confirmar que um download não foi corrompido ou adulterado, antes de instalar um binário ou extrair um pacote.

**Considerações:**

- `sha256sum -c` espera o formato `<hash>  <nome-do-arquivo>` (duas espaços entre eles), o mesmo formato que o comando produz ao gerar o hash.
- Um checksum batendo só garante que o arquivo corresponde ao que o publicador assinou como correto; não prova por si só que o publicador é confiável. Para isso, veja a verificação de assinatura GPG abaixo.
- Prefira obter o checksum de um canal diferente do download (página oficial do projeto, release do GitHub), nunca do mesmo servidor que hospeda um espelho não oficial do arquivo.

---

## Verificar assinatura GPG de um pacote ou release

```bash
gpg --import chave-publica-do-projeto.asc
gpg --verify arquivo.tar.gz.asc arquivo.tar.gz
# gpg: Good signature from "Nome do Mantenedor <email>"
```

**Quando usar:** validar que um artefato foi assinado pela chave privada correspondente à chave pública do projeto, o que garante autenticidade além da integridade que um checksum sozinho oferece.

**Considerações:**

- `gpg --verify` compara o arquivo `.asc` (a assinatura) contra o arquivo original; os dois precisam estar no mesmo diretório, ou informe o caminho de ambos.
- Uma saída `Good signature` confirma que a assinatura é válida para a chave importada, mas o GPG também avisa `WARNING: This key is not certified with a trusted signature` quando a chave não está em nenhuma cadeia de confiança local; isso não invalida a assinatura, só indica que o GPG não pode atestar sozinho que a chave pertence de fato à pessoa ou projeto esperado.
- Compare o fingerprint da chave importada com o publicado no canal oficial do projeto antes de confiar nela: `gpg --fingerprint <identificador-ou-email>`.

---

## Verificar a proveniência de uma imagem ou artefato assinado (cosign)

```bash
# Verificação por chave pública, quando o publicador distribui uma chave cosign
cosign verify --key cosign.pub docker.io/organizacao/imagem:tag

# Verificação "keyless", com identidade vinculada a um provedor OIDC (ex.: GitHub Actions)
cosign verify \
  --certificate-identity-regexp "https://github.com/organizacao/.*" \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com \
  docker.io/organizacao/imagem:tag

# Verificar a atestação de proveniência SLSA associada à imagem
cosign verify-attestation --type slsaprovenance \
  --certificate-identity-regexp "https://github.com/organizacao/.*" \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com \
  docker.io/organizacao/imagem:tag
```

**Quando usar:** confirmar não só que um artefato não foi corrompido (o que um checksum já garante), mas que ele foi assinado por uma identidade específica e, quando houver atestação de proveniência, que foi de fato produzido pelo pipeline de build esperado, a partir do repositório e commit esperados.

**Considerações:**

- Checksum, assinatura e proveniência respondem perguntas diferentes e nenhuma substitui as outras: checksum (`sha256sum`) prova integridade, o arquivo é bit a bit igual ao publicado; assinatura (`cosign verify`, `gpg --verify`) prova autenticidade, o arquivo foi assinado por uma identidade específica; proveniência (`cosign verify-attestation --type slsaprovenance`) prova origem do processo, em quais condições e a partir de qual código-fonte o artefato foi construído.
- A sintaxe do `cosign` muda entre versões e entre o fluxo por chave e o fluxo keyless; até a escrita deste texto, os exemplos acima refletem o fluxo keyless documentado para GitHub Actions. Confirme a sintaxe atual na [documentação oficial do Sigstore](https://docs.sigstore.dev/cosign/verifying/verify/) antes de usar em um pipeline.
- Nem todo artefato publicado tem assinatura ou atestação de proveniência disponível; a ausência não é necessariamente um sinal de risco, mas limita o que dá para verificar automaticamente antes do uso.
- Para o que o modelo de proveniência define e por que ele existe, veja a referência a SLSA e Sigstore em [ciclo de vida da imagem de container](../../../learn/containers/image-lifecycle/#fontes-e-leitura-adicional).

---

## Criptografar um arquivo simetricamente com age

```bash
age -p -o arquivo.age arquivo
# Pede uma passphrase interativamente e grava o resultado cifrado em arquivo.age
```

**Quando usar:** proteger um arquivo isolado (backup local, export de segredo) com uma senha, sem precisar gerenciar um par de chaves.

**Considerações:**

- `-p` ativa o modo por passphrase (criptografia simétrica); sem essa flag, `age` espera um destinatário via `-r <chave-pública>` ou `-R <arquivo-com-chaves>`, o modo assimétrico usado pelo [SOPS com age](../../../guides/tasks/secrets/configure-sops-with-age/) para segredos versionados em Git.
- A senha nunca é gravada no arquivo cifrado; perdê-la torna o conteúdo irrecuperável, já que `age` não tem mecanismo de recuperação.
- Para arquivos grandes, `age` cifra em streaming, sem carregar o conteúdo inteiro na memória.

---

## Descriptografar um arquivo cifrado com age

```bash
age -d -o arquivo arquivo.age
# Pede a passphrase usada na criptografia
```

**Quando usar:** recuperar o conteúdo original de um arquivo cifrado com `age -p`.

**Considerações:**

- Sem `-o`, o conteúdo decifrado vai para a saída padrão, útil para encadear com outro comando: `age -d arquivo.age | tar -x`.
- Para arquivos cifrados com uma chave de identidade em vez de passphrase, use `-i identity.txt` no lugar da senha interativa; veja [proteger chaves age](../../../operations/backups/protect-age-keys/) para o modelo de chaves usado nos backups deste projeto.

---

## Relacionado

- [Gerar senha ou token aleatório](../random-values/) para usar como base de uma passphrase.
- [Inspecionar e converter certificados X.509](../certificates/), que cobre a criptografia assimétrica usada em TLS, distinta do uso simétrico de arquivo a arquivo tratado aqui.
