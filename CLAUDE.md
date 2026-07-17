# AGENTS.md

## Regras de execução

- Nunca execute comandos diretamente no host.
- Toda ferramenta, script, validação, build, teste, lint ou comando auxiliar deve ser executado dentro de um contêiner Docker ou Podman.
- Prefira Podman quando estiver disponível e for compatível com o fluxo existente.
- Use imagens oficiais, confiáveis, versionadas e tão pequenas quanto possível.
- Nunca utilize `--privileged`.
- Conceda apenas as capacidades, dispositivos, volumes, portas e permissões estritamente necessários.
- Execute o contêiner como usuário não root sempre que possível.
- Não utilize `--network=host`, `--pid=host`, `--ipc=host` ou compartilhamento de namespaces do host, salvo quando isso for indispensável e estiver explicitamente autorizado.
- Não monte `/`, `/etc`, `/var/run`, `/run`, `/dev`, o diretório pessoal completo ou outros caminhos sensíveis do host.
- Nunca monte `/var/run/docker.sock` ou o socket do Podman, exceto quando houver autorização explícita.
- Monte arquivos e diretórios como somente leitura (`:ro`) sempre que não houver necessidade real de escrita.
- Limite o escopo dos volumes ao diretório específico necessário para a tarefa.
- Não publique portas no host quando a comunicação puder ocorrer apenas pela rede interna do contêiner.
- Quando uma porta precisar ser publicada, vincule-a a `127.0.0.1`, salvo quando o acesso externo for um requisito explícito.
- Remova capacidades Linux desnecessárias, preferencialmente começando com:

```bash
--cap-drop=ALL
```

- Adicione capacidades individualmente somente quando forem indispensáveis.
- Use filesystem raiz somente leitura sempre que possível:

```bash
--read-only
```

- Use `tmpfs` para diretórios temporários que precisem de escrita.
- Defina limites de CPU, memória, processos e arquivos quando aplicável.
- Não reutilize credenciais, chaves, tokens ou configurações pessoais do host dentro do contêiner.
- Nunca inclua segredos diretamente em comandos, imagens, Dockerfiles, arquivos versionados ou logs.
- Não execute imagens sem tag ou com a tag `latest`; fixe uma versão explícita e, quando relevante, um digest.
- Não faça download e execução direta de scripts remotos com construções como:

```bash
curl URL | sh
wget -qO- URL | bash
```

- Quando um artefato externo for necessário, faça o download dentro do contêiner, valide sua origem e integridade e somente então execute-o.
- Não instale pacotes, altere configurações, crie usuários, habilite serviços ou modifique o sistema operacional do host.
- Não utilize `sudo` no host.
- Não interrompa, reinicie ou altere serviços do host.
- Não remova arquivos ou volumes persistentes sem autorização explícita.

## Comportamento esperado

Antes de executar qualquer comando:

1. Identifique a imagem de contêiner adequada.
2. Determine os menores privilégios necessários.
3. Defina somente os mounts indispensáveis.
4. Prefira mounts somente leitura.
5. Remova todas as capabilities e adicione apenas as estritamente necessárias.
6. Evite acesso à rede, salvo quando necessário.
7. Mostre claramente qualquer operação destrutiva antes de executá-la.

Exemplo preferencial com Podman:

```bash
podman run \
  --rm \
  --userns=keep-id \
  --cap-drop=ALL \
  --security-opt=no-new-privileges \
  --read-only \
  --tmpfs /tmp:rw,noexec,nosuid,size=128m \
  --network=none \
  --mount type=bind,src="$PWD",dst=/workspace,ro \
  --workdir /workspace \
  IMAGE:VERSAO \
  COMANDO
```

Exemplo preferencial com Docker:

```bash
docker run \
  --rm \
  --user "$(id -u):$(id -g)" \
  --cap-drop=ALL \
  --security-opt=no-new-privileges \
  --read-only \
  --tmpfs /tmp:rw,noexec,nosuid,size=128m \
  --network=none \
  --mount type=bind,src="$PWD",dst=/workspace,readonly \
  --workdir /workspace \
  IMAGE:VERSAO \
  COMANDO
```

Os exemplos devem ser adaptados à tarefa, preservando o princípio de menor privilégio.

## Exceções

Caso uma tarefa não possa ser realizada dentro de um contêiner:

- Não execute o comando diretamente no host.
- Explique qual limitação impede o uso de Docker ou Podman.
- Apresente o comando necessário apenas como instrução para revisão manual.
- Aguarde autorização explícita antes de qualquer ação que afete o host.

A conveniência nunca deve prevalecer sobre o isolamento, a reprodutibilidade e o princípio de menor privilégio.
