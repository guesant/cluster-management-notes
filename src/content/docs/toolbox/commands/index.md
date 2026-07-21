---
title: Comandos rápidos (cookbook)
sidebar:
  order: 2
---

Esta seção reúne recipes de comandos organizadas por tarefa, não por ferramenta. Cada recipe cobre uma tarefa pequena, com um ou dois comandos e o contexto necessário para saber quando usá-los. A diferença para um task guide (que tem múltiplos passos, decisões e validação) é que uma recipe é um fragmento pronto para copiar e executar, sem uma sequência maior por trás.

## Por categoria

- [Valores aleatórios](../random-values/): senhas, tokens, chaves.
- [Certificados](../certificates/): criar, inspecionar e converter certificados.
- [Criptografia](../cryptography/): hashes, verificação de checksum, assinatura GPG e cifragem simétrica de arquivos.
- [DNS](../dns/): resolução, testes e troubleshooting.
- [Rede](../networking/): conectividade, rotas e portas.
- [Firewalls](../firewalls/): inspecionar regras, portas liberadas e log de pacotes descartados no UFW, firewalld e nftables.
- [Processos](../processes/): listar, encerrar e priorizar.
- [Troubleshooting genérico](../troubleshooting/): histórico, redirecionamento, paralelismo.
- [Filesystems](../filesystems/): montagem, permissões, inodes.
- [Discos e volumes](../disks-and-volumes/): dispositivos de bloco, UUID e saúde SMART.
- [Systemd](../systemd/): serviços, timers, logs.
- [Logs](../logs/): journal completo, boots anteriores, prioridade e log do kernel.
- [Containers (Docker)](../containers/): listar, inspecionar, build e push.
- [Kubernetes](../kubernetes/): `kubectl`, logs, port-forward, recursos.
- [Helm](../helm/): releases, values efetivos, histórico, rollback e `helm template`.
- [Git](../git/): branches, commits, stash, push e pull.

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
