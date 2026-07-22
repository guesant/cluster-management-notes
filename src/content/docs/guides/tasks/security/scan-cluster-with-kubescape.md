---
title: Varrer um cluster com Kubescape
description: Como rodar uma varredura de postura contra um kubeconfig real, ler a tabela de controles e o compliance score, priorizar o que corrigir primeiro por severidade, e documentar exceções em vez de ignorar falsos positivos silenciosamente.
sidebar:
  order: 1
---

> **Pré-requisitos:** `kubeconfig` com acesso de leitura ao cluster alvo, Kubescape rodando dentro de um container (imagem oficial `quay.io/kubescape/kubescape-cli`), nunca instalado direto no host de operação.
> **Versões testadas:** Kubescape v3.0.46.

Este procedimento aplica, contra um cluster real, o [modelo mental de Kubescape](../../../../learn/security/kubescape/) já coberto na trilha de aprendizado: o que uma varredura analisa, o que o compliance score significa, e por que scanner não substitui enforcement.

## O que isto modifica

Nada, por padrão: uma varredura só lê recursos do cluster via a API, sem alterar nada. A única modificação possível é de fora do cluster: sem a flag `--keep-local`, o Kubescape envia os resultados da varredura para o backend SaaS da Kubescape (ARMO), o que pode não ser aceitável dependendo da política de dados do ambiente; use `--keep-local` para manter o resultado inteiramente local.

## Rodar a varredura contra o cluster

> **Executar em:** estação administrativa ou control node, dentro de um container, nunca com o binário instalado direto no host.

```bash
kubescape scan framework nsa --kubeconfig /caminho/para/kubeconfig --keep-local
```

**Considerações:**

- `framework nsa` varre contra o framework NSA/CISA especificamente; trocar por `mitre` ou `cis` (ou omitir `framework <nome>` para o conjunto padrão) muda o conjunto de controles avaliados, não o mecanismo de varredura.
- Sem `--kubeconfig`, o Kubescape usa o contexto atual do `kubectl` (`current-context`); em ambientes com múltiplos clusters configurados, confirme qual contexto está ativo antes de rodar, ou use `--kube-context <nome>` para apontar explicitamente.
- `--include-namespaces`/`--exclude-namespaces` restringem o escopo da varredura a um subconjunto de namespaces, útil para focar a primeira varredura num ambiente menor antes de rodar contra o cluster inteiro.

## Ler o resultado

A saída padrão resume o resultado em duas tabelas: uma visão geral de controles passados/falhados, e uma tabela por controle com severidade e compliance score:

```text
╭─────────────────┬────╮
│        Controls │ 20 │
│          Passed │ 11 │
│          Failed │ 9  │
│ Action Required │ 0  │
╰─────────────────┴────╯

Failed resources by severity:

╭──────────┬───╮
│ Critical │ 0 │
│     High │ 3 │
│   Medium │ 5 │
│      Low │ 1 │
╰──────────┴───╯

╭──────────┬──────────────────────────────────────┬──────────────────┬───────────────┬──────────────────╮
│ Severity │ Control name                         │ Failed resources │ All Resources │ Compliance score │
├──────────┼──────────────────────────────────────┼──────────────────┼───────────────┼──────────────────┤
│   High   │ Privileged container                 │         1        │       1       │        0%        │
│  Medium  │ Non-root containers                  │         1        │       1       │        0%        │
├──────────┼──────────────────────────────────────┼──────────────────┼───────────────┼──────────────────┤
│          │           Resource Summary            │         1        │       1       │      55.00%      │
╰──────────┴──────────────────────────────────────┴──────────────────┴───────────────┴──────────────────╯
```

**Considerações:**

- A linha "Resource Summary" no final é o compliance score geral já discutido na página conceitual: um percentual ponderado por severidade, não uma contagem simples de controles.
- `-v`/`--verbose` expande a saída para listar cada recurso individualmente sob cada controle, necessário para identificar exatamente qual Deployment, Pod ou outro recurso causou uma falha, em vez de só o nome do controle.
- `kubescape scan control <ID> --kubeconfig ... -v` (o ID de controle aparece na tabela de resultado, como `C-0057` para "Privileged container") isola a investigação a um único controle, útil depois de já ter a visão geral e querer aprofundar um item específico.

## Priorizar descobertas por severidade

Numa primeira varredura contra um cluster que nunca passou por isso, o número de falhas costuma ser grande demais para corrigir tudo de uma vez. Priorizar por severidade, não pela ordem em que a ferramenta lista os controles, evita gastar o esforço inicial em itens de baixo impacto:

```bash
kubescape scan framework nsa --kubeconfig /caminho/para/kubeconfig \
  --keep-local --severity-threshold High
```

**Considerações:**

- `--severity-threshold` faz o comando retornar código de saída diferente de zero quando existe pelo menos uma falha na severidade indicada ou acima, o mecanismo que torna essa flag útil tanto para gate de CI (falhar o pipeline só acima de um limiar) quanto para uma primeira triagem manual focada no que é mais urgente.
- `--compliance-threshold <percentual>` é o mecanismo equivalente baseado no score agregado, em vez de severidade individual; as duas flags servem propósitos diferentes e podem ser combinadas.
- Corrigir controles `High`/`Critical` primeiro, mesmo que existam dezenas de falhas `Low`, reduz o risco real mais rápido do que perseguir o número total de falhas.

## Documentar uma exceção, em vez de ignorar silenciosamente

Quando uma falha é avaliada e considerada um falso positivo ou um risco aceito deliberadamente (já discutido na página conceitual desta trilha), registre isso como uma exceção formal, não como um controle simplesmente ignorado sem rastro:

```json
[
  {
    "name": "exclude-batch-jobs-sem-limits",
    "policyType": "postureExceptionPolicy",
    "actions": ["alertOnly"],
    "resources": [
      {
        "designatorType": "Attributes",
        "attributes": {
          "namespace": "batch",
          "kind": "Job"
        }
      }
    ],
    "posturePolicies": [
      {
        "controlID": "C-0009"
      }
    ]
  }
]
```

```bash
kubescape scan framework nsa --kubeconfig /caminho/para/kubeconfig \
  --keep-local --exceptions exceptions.json
```

**Considerações:**

- `resources` declara a quais recursos a exceção se aplica (por namespace, `kind`, nome ou labels); `posturePolicies` declara a quais controles ela vale, por `controlID` (como visto na tabela de resultado) ou por nome de framework. Múltiplas entradas em cada lista se combinam por OR, não AND.
- Versionar o arquivo de exceções junto com o resto da configuração do cluster (o mesmo repositório GitOps, por exemplo) é o que transforma uma decisão de risco aceito num registro auditável, em vez de conhecimento tácito de quem rodou o comando na hora.
- Uma exceção sem justificativa registrada em algum lugar (mensagem de commit, comentário no PR que a introduziu) é quase tão ruim quanto nenhuma exceção: alguém revisando o cluster meses depois precisa entender por que aquela falha foi aceita, não só que foi.

## Resultado esperado

Um relatório com controles passados/falhados, tabela de severidade, e um compliance score agregado. Nenhuma alteração no cluster. Com `--severity-threshold` ou `--compliance-threshold`, o código de saída reflete se o limiar definido foi respeitado, utilizável diretamente como gate de pipeline.

## Como executar novamente

Seguro rodar quantas vezes for necessário; é uma operação somente leitura. Rodar periodicamente (agendado em CI, ou manualmente após mudanças relevantes) é o uso recomendado, não uma varredura única tratada como aprovação permanente, já que novos recursos aplicados depois da última varredura não foram avaliados.

## Como remover ou desfazer

Não aplicável: o comando não altera o cluster. Remover o arquivo de exceções (se criado) reverte esse arquivo à ausência de exceções registradas, sem afetar o cluster em si.

## Troubleshooting

Se a varredura falhar ao carregar políticas/frameworks (erro mencionando não conseguir alcançar o backend do Kubescape), confirme que o container tem acesso de rede de saída para baixar as definições de framework na primeira execução; execuções subsequentes reaproveitam cache local. Se `--kubeconfig` for ignorado e a varredura atingir o cluster errado, confirme que nenhuma variável de ambiente `KUBECONFIG` está definida no container sobrepondo a flag, e que `--kube-context` não está apontando para um contexto diferente do esperado dentro desse kubeconfig.

## Páginas relacionadas

- [Kubescape: modelo mental, não lista de comandos](../../../../learn/security/kubescape/): o que este procedimento aplica na prática, incluindo o que um compliance score significa.
- [Policy Enforcement — OPA, Kyverno e Pod Security Admission](../../../../learn/security/policy-enforcement/): a camada que bloqueia na admissão, complementar a esta varredura.
- [Ferramentas de varredura e verificação de postura](../../../../toolbox/tools/security/scanning-tools/): Trivy e kube-bench, com sobreposição parcial de escopo.

## Referências

- [Kubescape: Scanning frameworks and controls](https://kubescape.io/docs/frameworks/): documentação oficial dos frameworks e flags de varredura.
- [Kubescape: Accepting risk](https://kubescape.io/docs/accepting-risk/): formato oficial do arquivo de exceções.
- [Kubescape (repositório oficial)](https://github.com/kubescape/kubescape): código-fonte e changelog de versões.
