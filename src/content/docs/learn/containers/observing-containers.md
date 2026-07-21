---
title: Observando containers de fora
description: Como usar strace, lsns e nsenter para diagnosticar um container já em execução a partir do host, e o bubblewrap como isolamento leve sem engine de container.
sidebar:
  order: 7
---

> **Para quem é:** quem já entende os mecanismos individuais (namespaces, cgroups, capabilities, filesystem) e quer as ferramentas para observar esses mecanismos agindo sobre um container real, já em execução.

As páginas anteriores desta seção explicaram cada mecanismo isoladamente, muitas vezes demonstrando com um processo criado especificamente para a demonstração (`unshare`, por exemplo). Esta página cobre o outro lado: como investigar um container que já está rodando, a partir do host, sem modificar nada dentro dele.

## `strace`: observar as chamadas de sistema de um processo confinado

`strace` intercepta e imprime cada chamada de sistema que um processo faz, incluindo um processo que já está confinado por namespaces, cgroups e capabilities. Para observar um container em execução, primeiro descubra o PID do seu processo principal no host, depois anexe o `strace` a esse PID:

```bash
# Descobrir o PID do processo principal do container
docker inspect --format '{{.State.Pid}}' <container>

# Anexar o strace a esse processo, já em execução
sudo strace -p <PID>

# Só chamadas relacionadas a arquivos, mais fácil de ler em um processo ruidoso
sudo strace -p <PID> -e trace=open,openat,read,write
```

**Quando usar:** diagnosticar por que um processo dentro de um container está travado, lento ou falhando de um jeito que os logs da aplicação não explicam, observando exatamente quais chamadas de sistema ele está fazendo (ou tentando fazer) no momento do problema.

**Considerações:** `strace` usa a chamada de sistema `ptrace(2)` para interceptar as chamadas do processo alvo, o que exige a capability `CAP_SYS_PTRACE` (ou root) de quem executa o `strace`. Anexar de fora, a partir do host, é o caminho mais confiável: rodar `strace` de dentro do próprio container confinado pode falhar se o perfil seccomp daquele container bloquear `ptrace` para o próprio processo, uma restrição comum em perfis padrão de segurança. Anexar a um processo em produção também pausa brevemente esse processo a cada chamada de sistema interceptada, um custo de performance a considerar antes de usar em um serviço sensível a latência.

## `lsns` e `nsenter` aplicados a um container real

O procedimento genérico de [inspecionar namespaces com `lsns`](../namespaces/#inspecionar-namespaces-com-lsns) e [entrar em um namespace com `nsenter`](../namespaces/#entrar-em-um-namespace-existente-com-nsenter) se aplica diretamente a um container em execução, usando o mesmo PID descoberto acima:

```bash
# Quais namespaces esse container ocupa
lsns -p <PID>

# Entrar no namespace de rede do container para diagnosticar conectividade
# com as ferramentas do host, sem precisar delas instaladas na imagem do container
sudo nsenter --target <PID> --net ip addr
sudo nsenter --target <PID> --net ss -tlnp
```

**Quando usar:** um caso comum é uma imagem de container mínima, sem `ip`, `ss` ou outras ferramentas de diagnóstico de rede instaladas; em vez de instalar essas ferramentas dentro da imagem só para depurar, `nsenter --net` empresta o namespace de rede do container para um comando rodado com as ferramentas já disponíveis no host.

## `bubblewrap`: isolamento leve sem engine de container

`bubblewrap` (`bwrap`) usa os mesmos mecanismos de kernel discutidos nesta seção (namespaces, seccomp) para isolar um único comando, sem exigir um daemon, um formato de imagem ou um registry. Em vez de uma imagem OCI, cada invocação de `bwrap` declara explicitamente, por linha de comando, o que o processo isolado vai enxergar: quais caminhos ficam disponíveis (e se somente leitura ou graváveis), quais namespaces são criados, o que fica montado como `tmpfs`.

```bash
bwrap \
  --ro-bind /usr /usr \
  --ro-bind /lib /lib \
  --tmpfs /tmp \
  --unshare-all \
  --die-with-parent \
  /bin/sh
```

**Quando usar:** isolar um comando pontual sem a sobrecarga de um daemon de container completo, ou como base para outra ferramenta construir uma sandbox própria; o Flatpak, por exemplo, usa `bubblewrap` internamente para isolar aplicações de desktop, sem que o usuário final interaja com o `bwrap` diretamente.

**Considerações:** `--unshare-all` cria todos os namespaces possíveis para o processo; sem `--share-net` (omitido no exemplo acima), a rede fica isolada por padrão, então o comando dentro do sandbox não tem acesso à rede a menos que essa flag seja adicionada explicitamente. `--die-with-parent` garante que o processo isolado termine se o processo que invocou o `bwrap` terminar, evitando um processo órfão continuar rodando fora do controle de quem o iniciou. Diferente de Docker ou Podman, `bubblewrap` não gerencia camadas de imagem nem copy-on-write: cada invocação monta os caminhos do host diretamente (como bind mounts, majoritariamente somente leitura), então não existe o conceito de "imagem" a versionar ou distribuir, só a lista de argumentos que descreve o isolamento desejado.

## Referências

- [`strace(1)`](https://man7.org/linux/man-pages/man1/strace.1.html): opções de filtro e anexação a um processo já em execução.
- [`ptrace(2)`](https://man7.org/linux/man-pages/man2/ptrace.2.html): a chamada de sistema por trás do `strace`, e os privilégios que ela exige.
- [`lsns(1)`](https://man7.org/linux/man-pages/man1/lsns.1.html) e [`nsenter(1)`](https://man7.org/linux/man-pages/man1/nsenter.1.html): já referenciados em [namespaces do kernel](../namespaces/#referências).
- [Bubblewrap: documentação oficial](https://github.com/containers/bubblewrap): sintaxe completa de flags e o modelo de sandbox por linha de comando.
