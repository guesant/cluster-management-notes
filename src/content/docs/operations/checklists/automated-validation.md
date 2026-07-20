---
title: Validação automatizada de cluster
sidebar:
  order: 10
---

> **Para quem é:** operadores que já percorrem os checklists deste notebook manualmente e querem transformar parte da verificação em script, para rodar sob demanda ou integrar ao CI.

Os checklists especializados deste notebook (segurança do host, segurança do cluster, prontidão de workloads, observabilidade, backup) descrevem cada item como uma pergunta, uma explicação e um comando de verificação. Essa estrutura já é, por si só, um roteiro para automação: qualquer item cujo comando de verificação produza uma saída objetiva (zero linhas, um valor esperado, um código de saída) pode virar uma função de script em vez de uma etapa manual. Esta página documenta o único script de verificação já implementado no repositório e o padrão a seguir para os demais, que ainda não existem.

## O script existente: verificação de saúde básica

`src/scripts/check-cluster-health.sh` cobre um subconjunto pequeno e genérico de verificações, útil como smoke test rápido antes de investir tempo em um diagnóstico manual mais profundo: confirma que `kubectl`, `helm` e `jq` estão disponíveis, que o cluster responde, que todos os nós estão `Ready`, que não há Pods fora de `Running`/`Succeeded` e que a API responde a `kubectl api-resources`.

```bash
./src/scripts/check-cluster-health.sh
```

A saída inclui um resumo legível no terminal e, ao final, um relatório em JSON:

```json
{
  "timestamp": "2026-07-19T10:30:00Z",
  "summary": {
    "total": 7,
    "passed": 7,
    "failed": 0
  },
  "checks": {
    "cmd_kubectl": "pass",
    "cmd_helm": "pass",
    "cmd_jq": "pass",
    "cluster_accessible": "pass",
    "nodes_ready": "pass",
    "pods_running": "pass",
    "api_responsive": "pass"
  }
}
```

Esse script não substitui os checklists especializados: ele confirma que o cluster está minimamente acessível e saudável, não que RBAC, NetworkPolicies, probes ou backups estão corretos. Trate-o como um pré-requisito rápido antes de investir tempo em uma verificação mais profunda, não como prova de prontidão.

## Integração no CI

`.github/workflows/scripts.yml` roda automaticamente a cada push ou pull request que altere algo em `src/scripts/`, com três jobs: `shellcheck` valida a sintaxe e os problemas comuns de todos os scripts do diretório; `smoke-test` confirma que cada script tem sintaxe válida (`bash -n`) e que as funções principais da biblioteca compartilhada (`src/scripts/lib/common.sh`) existem e respondem como esperado; `lint` verifica se os scripts são executáveis e faz uma busca simples por padrões que sugerem segredos hardcoded (`password`, `secret`, `token`, `key`), emitindo um aviso sem falhar o pipeline. Esse workflow valida os scripts do repositório, não o estado de um cluster real; ele não substitui a execução de `check-cluster-health.sh` contra um cluster específico.

## Padrão para novos scripts de validação

Os demais checklists especializados ainda não têm um script correspondente. Quando um for criado, o padrão sugerido é nomear o script a partir do checklist que ele valida e devolver o mesmo formato de relatório já usado por `check-cluster-health.sh`, para que os resultados possam ser agregados de forma consistente:

```json
{
  "timestamp": "ISO 8601",
  "checklist": "nome do checklist validado",
  "summary": {
    "total": 0,
    "passed": 0,
    "failed": 0,
    "warnings": 0
  },
  "results": [
    {
      "name": "nome do item verificado",
      "status": "pass|fail|warning",
      "message": "detalhe da verificação"
    }
  ]
}
```

Nem todo item de um checklist é automatizável dessa forma. Itens que exigem revisão manual de um documento, confirmação de um processo humano (como um responsável de escalonamento definido) ou julgamento sobre um trade-off não têm um comando de verificação objetivo e devem continuar como itens manuais do checklist, não como uma função de script forçada a devolver `pass`/`fail` sem sentido real. Os candidatos mais diretos a automação são os itens de [segurança do host](../host-security/), [segurança do cluster](../cluster-security/) e [prontidão de workloads](../application-readiness/), porque a maioria de seus comandos de verificação já produz uma saída objetiva (estado de um serviço, presença de uma label, ausência de uma tag de imagem flutuante) sem depender de julgamento humano.

## Próximo passo

Antes de escrever um novo script de validação, escolha um checklist especializado e confirme quantos dos seus itens realmente têm um comando de verificação objetivo o suficiente para virar uma função automatizável; os demais permanecem como itens manuais no mesmo checklist.

## Fontes e leitura adicional

- [check-cluster-health.sh (código-fonte no repositório)](https://github.com/guesant/infrastructure-and-cluster-notebook/blob/main/src/scripts/check-cluster-health.sh): implementação de referência do padrão de saída em JSON usado por este script.
- [Guia de operação contínua](../cluster-operational-checklist/): índice dos checklists especializados candidatos a automação.
