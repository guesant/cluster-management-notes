---
title: Decisões do projeto
description: Registro de decisões arquiteturais e editoriais tomadas para o notebook.
sidebar:
  order: 3
---

Este registro reúne decisões que afetam a estrutura ou o conteúdo do projeto como um todo, para
que não precisem ser redescobertas ou re-discutidas a cada nova página.

## Estrutura de diretórios da documentação (2026-07-18)

**Decisão:** migrar integralmente para a estrutura de diretórios proposta no plano de conteúdo
(`.todo/todo.txt`, seção 3), em vez de adaptar a proposta à estrutura atual ou manter uma
estrutura híbrida.

**Estrutura alvo:**

```text
docs/
├── index.md
├── getting-started/
├── learn/
├── guides/
│   ├── blueprints/
│   └── tasks/
├── operations/
├── toolbox/
│   ├── tools/
│   ├── commands/
│   ├── snippets/
│   ├── scripts/
│   └── labs/
├── technologies/
├── resources/
├── reference/
├── contributing/
└── project/
```

**Estrutura atual (antes da migração):** `getting-started/`, `concepts/`, `hosts/`,
`kubernetes/{k3s,networking,security,extensions,workloads}`,
`guides/{deployment,secrets,operations-overview}`, `operations/`, `reference/`, `project/`,
`contributing/`.

**Por que:** as árvores de arquivo detalhadas em todas as fases do plano (2 a 9) assumem a
estrutura nova (`learn/`, `guides/blueprints/`, `guides/tasks/`, `toolbox/`, `technologies/`,
`resources/`). Adaptar cada item de fase para caber na estrutura atual exigiria reescrever o
mapeamento de conteúdo inteiro antes de começar a criar páginas, e ainda deixaria a estrutura
menos alinhada ao princípio central da proposta (separar Learn/Guides/Operations/Toolbox/
Resources/Reference como tipos de conteúdo, não como hierarquia de tecnologia).

**Consequência:** a migração em si foi um item do escopo da Fase 1 do plano de conteúdo interno
(`.todo/phase-1-fundacao-editorial.md`, fora do site publicado): mover conteúdo existente para os
diretórios novos, atualizar a navegação do Starlight e corrigir links internos.

**Estado atual:** a migração está concluída. A árvore publicada em `src/content/docs/` corresponde
à estrutura alvo (`getting-started/`, `learn/`, `guides/blueprints/`, `guides/tasks/`,
`operations/`, `toolbox/`, `technologies/`, `resources/`, `reference/`, `contributing/`,
`project/`), e nenhum diretório da estrutura antiga (`concepts/`, `hosts/`, `kubernetes/`,
`guides/{deployment,secrets,operations-overview}`) permanece. As subseções `toolbox/scripts/` e
`toolbox/labs/` previstas na árvore alvo original não foram criadas como seções próprias do site:
scripts maiores vivem em `src/scripts/` (fora do site publicado) e são incorporados às páginas via
os componentes `ScriptHelper`/`FileWriter`, conforme registrado em
[política de conteúdo](../content-policy/).
