---
title: Aviso sobre uso de IA
description: Escopo do aviso sobre conteúdo elaborado ou revisado com apoio de inteligência artificial e responsabilidade de validação do leitor.
sidebar:
  order: 2
---

:::note
As anotações deste guia foram elaboradas e revisadas com o apoio de assistentes de inteligência
artificial (incluindo, ao longo do desenvolvimento do projeto, ferramentas como ChatGPT e Claude).
Alguns scripts e outros conteúdos deste repositório também podem ter sido criados ou modificados
com auxílio de IA. Valide o código, os comandos, as versões e as decisões de segurança de acordo
com o seu ambiente antes de utilizá-los.
:::

## O que este aviso cobre

O aviso acima aparece no rodapé de toda página deste site porque se aplica de forma transversal:
texto explicativo, comandos, exemplos de configuração, scripts em `scripts/` e templates em
`templates/` podem ter passado por elaboração ou revisão assistida por IA em algum momento do
projeto.

Isso não significa que todo trecho tenha sido gerado por IA, nem que o conteúdo esteja
necessariamente incorreto: significa que a fonte editorial do projeto usa essa ferramenta como
apoio, e que o processo de revisão humana não substitui a validação técnica do leitor.

## O que não está coberto

- Links para documentação oficial de terceiros (Kubernetes, K3s, Argo CD, cert-manager, etc.):
  esse conteúdo é de responsabilidade dos respectivos projetos, não deste repositório.
- Versões e números específicos citados como referência: consulte sempre a fonte upstream listada
  em [Escopo, convenções e versões](../../reference/conventions/) antes de aplicar em produção.

## Responsabilidade de validação

Antes de executar qualquer comando ou aplicar qualquer configuração deste site:

- Leia o comando ou script por completo e entenda o que ele faz.
- Confirme que a versão sugerida é compatível com o seu ambiente.
- Teste primeiro em um ambiente descartável ou de homologação, nunca diretamente em produção.
- Trate blocos gerados por componentes interativos (como o construtor de comandos) da mesma
  forma: eles facilitam a montagem do comando, mas não substituem a leitura antes da execução.

Dúvidas, imprecisões ou sugestões de correção podem ser reportadas abrindo uma issue no
[repositório no GitHub](https://github.com/guesant/infrastructure-and-cluster-notebook).
