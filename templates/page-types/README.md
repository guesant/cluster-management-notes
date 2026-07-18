# Templates de página por tipo de conteúdo

Copie o arquivo correspondente para `src/content/docs/<seção>/` e preencha os placeholders
(`<...>`). Nenhum desses arquivos é publicado — eles ficam fora de `src/content/docs/` de
propósito, como os templates GitOps em `templates/gitops/`.

Critérios completos (o que faz uma página estar "concluída") estão em
`.todo/quality-criteria.md`. Alguns já são resolvidos automaticamente e não precisam de campo
manual no template:

- **Data da última revisão**: `lastUpdated: true` está ligado globalmente em
  `astro.config.mjs` — a data vem do histórico do Git. Só use `lastUpdated:` no front matter de
  uma página específica se precisar sobrepor esse valor.
- **Aviso do projeto disponível**: o rodapé (`src/components/overrides/Footer.astro`) já injeta
  `ProjectDisclaimer` em toda página. Não precisa linkar o disclaimer manualmente.

## Qual template usar

| Pergunta que a página responde | Template | Fica em |
|---|---|---|
| Como algo funciona, quais são as alternativas, quando usar cada uma? | `learn.md` | `learn/<tema>/` |
| Uma arquitetura pronta e opinativa, do início ao fim? | `guide-blueprint.md` | `guides/blueprints/<nome>/` |
| Como fazer uma coisa específica (um único objetivo)? | `guide-task.md` | `guides/tasks/<domínio>/` |
| Como manter, atualizar, diagnosticar ou recuperar algo que já existe? | `operation.md` | `operations/<checklists\|maintenance\|upgrades\|backups\|disaster-recovery\|troubleshooting>/` |
| Uma ferramenta específica (o que é, quando usar, riscos)? | `toolbox-tool.md` | `toolbox/tools/<categoria>/` |
| Um comando pronto para copiar, organizado por tarefa? | `toolbox-command.md` | `toolbox/commands/` |
| Um dado técnico objetivo (porta, variável, convenção)? | `reference.md` | `reference/` |

Se a página tentar responder mais de uma dessas perguntas ao mesmo tempo, ela provavelmente
deveria ser duas páginas — ver "ausência de duplicação desnecessária" e "tipo de conteúdo
correto" em `.todo/quality-criteria.md`.
