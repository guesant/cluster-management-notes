---
title: Comandos rápidos (cookbook)
sidebar:
  order: 2
---

Esta seção reúne recipes de comandos organizadas por tarefa, não por ferramenta. Cada recipe cobre uma tarefa pequena, com um ou dois comandos e o contexto necessário para saber quando usá-los. A diferença para um task guide (que tem múltiplos passos, decisões e validação) é que uma recipe é um fragmento pronto para copiar e executar, sem uma sequência maior por trás.

## Por categoria

- [Valores aleatórios](../random-values/): senhas, tokens, chaves.
- [Certificados](../certificates/): criar, inspecionar e converter certificados.
- [DNS](../dns/): resolução, testes e troubleshooting.
- [Rede](../networking/): conectividade, rotas e portas.
- [Processos](../processes/): listar, encerrar e priorizar.
- [Troubleshooting genérico](../troubleshooting/): histórico, redirecionamento, paralelismo.
- [Filesystems](../filesystems/): montagem, permissões, inodes.
- [Systemd](../systemd/): serviços, timers, logs.
- [Containers (Docker)](../containers/): listar, inspecionar, build e push.
- [Kubernetes](../kubernetes/): `kubectl`, logs, port-forward, recursos.
- [Git](../git/): branches, commits, stash, push e pull.

As categorias a seguir estão planejadas (Fase 7 do plano de conteúdo interno, `.todo/phase-7-toolbox.md`, fora do site publicado), mas ainda não foram escritas: criptografia (chaves e hashing além do já coberto em [certificados](../certificates/)), firewalls (UFW, firewalld, iptables), discos e volumes (partições, LVM), logs de aplicação (fora do escopo de [systemd](../systemd/)) e Helm (busca de charts, valores, releases).

## Formato de uma recipe

Cada recipe segue a mesma estrutura, para que uma pessoa acostumada com uma página já saiba onde encontrar a informação nas demais:

````markdown
## Tarefa

```bash
comando aqui
```

**Quando usar:** descrição breve de uma ou duas linhas, explicando o cenário.

**Considerações:**

- Efeito colateral ou flag relevante.
- Cuidado a observar antes de rodar o comando.
````
