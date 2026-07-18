---
title: Estilo de escrita
description: Convenções de tom, formatação e estrutura usadas nas páginas deste site.
sidebar:
  order: 2
---

Estas são as convenções que tornam as páginas deste site consistentes entre si, além do que já
está em [Política de conteúdo](../../project/content-policy/) (o que cada seção cobre).

## Tom

- Escreva em português, direto e objetivo — sem enrolação nem qualificadores vagos ("de certa
  forma", "pode ser que").
- Use segunda pessoa implícita ("configure", "execute"), não primeira ("nós vamos configurar").
- Explique o porquê de decisões não óbvias; não explique o óbvio (nomes de variáveis
  autoexplicativos não precisam de comentário).
- Riscos e efeitos colaterais aparecem antes do comando que os causa, não depois.

## Formatação

- Frontmatter: sempre `title` e `description`; `sidebar.order` quando a posição na seção
  importar.
- Blocos de comando: um bloco por passo lógico, não um script gigante — facilita copiar só o
  trecho necessário.
- Blocos que executam algo no host levam um callout `> **Executar em:** ...` antes, indicando
  onde rodar (host alvo, estação administrativa, etc.).
- Use `:::note`, `:::caution`, `:::danger` (asides do Starlight) para destacar risco, não texto
  em negrito solto no meio do parágrafo.
- Links internos são sempre relativos (`../outra-pagina/`), nunca absolutos com o domínio do
  site — o build falha visivelmente se o caminho relativo estiver errado (import quebrado ou
  link não resolvido), o que facilita pegar o erro cedo.

## Componentes interativos

- `<ScriptHelper>` e `<FileWriter>` (ver `src/components/`) só funcionam em arquivos `.mdx` —
  nunca em `.md`. Em `.md`, o import e a tag viram texto literal sem erro nenhum (ver
  [Decisões do projeto](../../project/decisions/)). Se a página usa qualquer componente,
  ela é `.mdx`.
- Scripts referenciados por `?raw` ficam em `src/scripts/`, nunca embutidos como string longa
  direto no `.mdx`.
- Um script que cria ou edita um arquivo no host segue o padrão já estabelecido: um script de
  "antes" (não depende do arquivo existir), um passo de criação do arquivo (aba de conteúdo
  estático + aba de script automatizado via `<FileWriter>`), e um script de "depois" (assume que
  o arquivo já existe) — não um único script monolítico fazendo tudo.

## Título e descrição

- `title`: substantivo ou frase nominal, não pergunta ("Instalar o cert-manager", não "Como
  instalo o cert-manager?").
- `description`: uma frase, resume o que a página faz — aparece em listagens e em buscadores,
  então precisa fazer sentido fora de contexto.

## O que evitar

- Duplicar um procedimento que já existe em outra página — linke em vez de copiar.
- Escrever uma página que mistura dois tipos de conteúdo (ver
  [Política de conteúdo](../../project/content-policy/)) — se está explicando conceito e também
  instalando algo, provavelmente são duas páginas.
- Prometer um resultado sem mostrar como validar que ele aconteceu.
