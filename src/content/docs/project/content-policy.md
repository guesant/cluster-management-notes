---
title: Política de conteúdo
description: O que cada seção do notebook cobre, o que fica fora dela, e o que torna uma página concluída.
sidebar:
  order: 4
---

Esta página define os limites de cada seção do site e o critério para considerar uma página
pronta. Ela existe para que uma dúvida como "isso é um `guide` ou uma `operation`?" tenha uma
resposta objetiva, em vez de depender de quem escreveu a página.

Para o "como escrever", não "onde colocar", veja os templates em `templates/page-types/` (fora do
site publicado) — cada tipo de conteúdo abaixo tem um template correspondente.

## O que cada seção cobre

### `learn/`

Conceitos, comparações e critérios de decisão. Responde "o que é", "qual problema resolve",
"quais são as alternativas", "quando usar", "quando evitar". Não instala nem configura nada — se
a página tem um bloco de comando que muda o sistema, ela não é `learn/`.

### `guides/blueprints/`

Arquiteturas prontas e opinativas, do início ao fim, para um cenário específico (ex.: cluster k3s
single-node com GitOps). Declara as decisões adotadas e aponta para os task guides canônicos em
vez de repetir os comandos.

### `guides/tasks/`

Procedimentos focados em um único objetivo (ex.: instalar o cert-manager, adicionar um agente).
São a fonte canônica dos comandos — blueprints e outras páginas devem linkar para cá, não copiar.

### `operations/`

Manutenção, atualização, diagnóstico e recuperação de algo que **já existe e já funciona**. A
diferença para `guides/tasks/`: um guia responde "como implementar ou configurar"; um item de
`operations/` responde "como manter, atualizar, diagnosticar ou recuperar o que já está rodando".

### `toolbox/`

Consulta rápida e descoberta: `tools/` (catálogo de ferramentas), `commands/` (cookbook de
comandos organizados por tarefa, não por ferramenta), `snippets/` (fragmentos pequenos e
reutilizáveis), `scripts/` (scripts maiores referenciados pela documentação).

### `technologies/`

Uma página central por tecnologia, funcionando como hub de navegação para quem já sabe o que está
procurando. Não duplica `learn/` nem `guides/` — só aponta para eles.

### `resources/`

Referências externas que não justificam uma página completa aqui: projetos relacionados,
documentações oficiais, listas `awesome-*`, laboratórios, cursos, comunidades.

### `reference/`

Dados técnicos objetivos — portas, variáveis, convenções, compatibilidade. Tabelas e listas, não
narrativa. Se a página está explicando "por que", ela pertence a `learn/`, não a `reference/`.

### `getting-started/`, `contributing/`, `project/`

Ficam fora da classificação acima por natureza: `getting-started/` é o roteiro de entrada,
`contributing/` documenta como contribuir com o próprio site, `project/` registra políticas e
decisões do projeto (como esta página).

## O que torna uma página concluída

Antes de considerar uma página pronta, verifique:

- objetivo explícito;
- público-alvo identificável;
- tipo de conteúdo correto (a seção bate com as definições acima);
- pré-requisitos listados;
- versões testadas registradas;
- comandos revisados;
- riscos destacados;
- resultado esperado;
- forma de validação;
- troubleshooting básico;
- rollback, quando aplicável;
- referências;
- links internos válidos;
- ausência de duplicação desnecessária — se o mesmo comando aparece em duas páginas, uma delas
  deveria linkar para a outra em vez de repetir;
- páginas relacionadas;
- próximo passo.

Blueprints (`guides/blueprints/`) têm critérios adicionais: declarar decisões opinativas,
apresentar a arquitetura, explicar limitações, identificar pontos únicos de falha, apontar para
operação/backup/recuperação.

Páginas com comandos ou scripts têm critérios adicionais: permissões necessárias, efeitos
colaterais, compatibilidade, idempotência, comportamento em caso de erro, remoção ou rollback,
tratamento de dados sensíveis.

A data da última revisão é automática (baseada no histórico do Git, não em um campo manual) e
aparece no rodapé de cada página.
