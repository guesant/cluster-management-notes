---
title: Ferramentas de administração do Docker
description: Catálogo de TUIs de administração e diagnóstico do Docker — lazydocker, ctop e dive — com o que avaliar antes de instalar cada uma.
sidebar:
  order: 1
---

> **Para quem é:** quem já usa `docker`/`docker compose` pela linha de comando (ver [cookbook de containers](../../commands/containers/)) e quer uma sessão interativa para navegar entre containers, acompanhar consumo de recursos em tempo real, ou entender por que uma imagem ficou grande.

Esta categoria cobre ferramentas específicas do Docker/Compose em um único host. Para administração visual de um cluster Kubernetes/K3s (k9s, Lens, Rancher, Portainer, Headlamp), veja [administração de hosts](../../host-management/) e a comparação em [ferramentas de gerenciamento visual](../../../learn/tools/visual-management/); `lazydocker` também aparece resumido na tabela de [Docker, Swarm e containers](../../overview/#docker-swarm-e-containers) do catálogo geral, esta página é o ponto de referência dedicado.

## lazydocker: TUI de administração do Docker

`lazydocker` reúne containers, imagens, volumes e redes em uma única interface de terminal navegável por teclado, com logs e estatísticas de recursos ao lado de cada item selecionado, em vez de alternar entre `docker ps`, `docker logs` e `docker stats` em terminais separados.

```bash
# Requer o toolchain Go instalado
go install github.com/jesseduffield/lazydocker@latest
```

Sem Go instalado, baixe o binário pré-compilado da arquitetura correspondente na [página de releases do projeto](https://github.com/jesseduffield/lazydocker/releases), valide o checksum publicado na mesma release antes de instalar em `/usr/local/bin`, e fixe uma versão específica em vez de sempre baixar a mais recente.

**Quando usar:** investigação interativa quando o objetivo é navegar e comparar vários containers ao mesmo tempo; para uma consulta pontual (listar, ver log de um container específico), os comandos do [cookbook de containers](../../commands/containers/) já resolvem sem abrir uma sessão interativa.

**Modelo de acesso e privilégios:** `lazydocker` se conecta ao socket do Docker (`/var/run/docker.sock`) com as mesmas permissões de qualquer outro cliente `docker`; qualquer identidade com acesso a esse socket já pode criar containers privilegiados e controlar o host, então rodar `lazydocker` não amplia nem reduz esse risco, apenas herda o mesmo nível de acesso que a CLI oficial exige.

**Riscos:** além de inspecionar, a interface expõe ações mutativas (parar, remover, podar) atrás de atalhos de teclado de fácil alcance; é mais fácil remover o item errado por engano em uma TUI densa do que ao digitar um comando `docker rm` explícito com o nome do alvo. Confirme o item selecionado antes de confirmar uma ação destrutiva.

## ctop: métricas de containers em tempo real

`ctop` é o equivalente do `top`/`htop` para containers: uma lista atualizada continuamente com uso de CPU, memória, rede e I/O por container, sem os campos de gerenciamento completo que `lazydocker` oferece.

```bash
go install github.com/bcicen/ctop@latest
```

Sem Go instalado, baixe o binário da arquitetura correspondente na [página de releases do projeto](https://github.com/bcicen/ctop/releases) e valide o checksum publicado antes de instalar.

**Quando usar:** identificar qual container está consumindo CPU ou memória em excesso em um host com vários containers rodando, o equivalente em nível de container do que [monitorar CPU e memória em tempo real](../../commands/processes/#monitorar-cpu-e-memória-em-tempo-real) já cobre em nível de processo do host.

**Riscos:** nenhum risco específico além do já coberto pelo acesso ao socket do Docker; `ctop` é somente leitura por padrão, sem ações mutativas na interface.

## dive: análise de camadas de imagem

`dive` abre uma imagem Docker e mostra o conteúdo de cada camada individualmente, o que cada camada adiciona, remove ou modifica, e uma pontuação de eficiência estimada com base em quanto espaço é desperdiçado por arquivos duplicados ou removidos em camadas posteriores (que continuam ocupando espaço na imagem final, mesmo invisíveis no filesystem resultante).

```bash
go install github.com/wagoodman/dive@latest

dive <imagem>:<tag>
```

Sem Go instalado, o projeto também publica pacotes `.deb`/`.rpm` e binários na [página de releases](https://github.com/wagoodman/dive/releases).

**Quando usar:** investigar por que uma imagem construída ficou maior do que o esperado, antes de otimizar o `Dockerfile` às cegas; `dive` aponta exatamente qual instrução do build adicionou qual conjunto de arquivos, o que orienta se o problema está em uma dependência de build não removida, um cache não limpo, ou uma camada intermediária desnecessária.

**Modelo de acesso:** `dive` só precisa ler a imagem já presente localmente (ou puxá-la do registry, com as mesmas credenciais que `docker pull` usaria); não modifica a imagem original, e qualquer imagem gerada durante a análise fica isolada da imagem inspecionada.

**Riscos:** nenhum risco específico; a ferramenta é somente leitura sobre a imagem analisada. O único cuidado prático é rodar a análise antes de publicar a imagem em um registry, para evitar redistribuir uma imagem inflada que já poderia ter sido corrigida.

## Referências

- [lazydocker — repositório oficial](https://github.com/jesseduffield/lazydocker): instalação, atalhos de teclado e configuração.
- [ctop — repositório oficial](https://github.com/bcicen/ctop): opções de filtro e formatos de exibição.
- [dive — repositório oficial](https://github.com/wagoodman/dive): critérios de eficiência, integração com CI e opções de linha de comando.
