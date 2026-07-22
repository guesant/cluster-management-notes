---
title: "Investigação: cmcli (CLI de diagnóstico)"
description: Registro aberto das perguntas de design que precisam de resposta antes de decidir se vale construir uma CLI de diagnóstico complementar a este notebook.
sidebar:
  order: 99
---

> **Status:** investigação aberta, sem compromisso de implementação.

`cmcli` é a hipótese de uma CLI somente leitura para diagnóstico rápido de clusters e hosts, complementando a documentação em vez de substituí-la. Esta página não descreve uma ferramenta que existe; ela reúne as perguntas de design que precisam de resposta antes de decidir se a implementação se justifica.

## Qual problema ela resolve melhor que shell scripts?

A alternativa mais simples é continuar com os shell scripts já existentes e os cookbooks do toolbox: eles são copiáveis, funcionam offline e não introduzem dependências extras, mas ficam dispersos entre páginas, com saída inconsistente entre um script e outro e nenhum formato de relatório comum. A hipótese por trás do `cmcli` é que uma CLI centralizaria essas verificações com saída estruturada (JSON ou YAML para consumo por outras ferramentas, formatada para humanos por padrão), um único ponto de descoberta (`cmcli help` listando tudo em um lugar) e funções de diagnóstico reutilizáveis em vez de duplicadas entre scripts.

O risco correspondente é que o CI e os próprios scripts do repositório precisam continuar funcionando sem depender de um binário adicional instalado; uma CLI centralizada não pode se tornar um pré-requisito silencioso para tarefas que hoje são self-contained.

## Quais verificações são portáveis?

O escopo inicial, somente leitura, cobriria `check host` (sistema operacional, CPU, RAM, disco, rede), `check k3s` (versão, nós, services, API), `check firewall` (regras do UFW ou firewalld, sem alterá-las), `check networking` (DNS, conectividade, latência), `check storage` (volumes, inodes, status do Longhorn), `checklist` (executar as verificações associadas a um checklist de operação) e `report` (gerar a saída estruturada consolidada).

Ficam fora do escopo, pelo menos nesta primeira hipótese, verificações para Windows ou macOS (o notebook cobre Debian/Ubuntu com K3s) e verificações de segredos (Infisical, OpenBao e SOPS têm modelos de acesso diferentes o suficiente entre si para que uma verificação genérica tenha pouco valor real).

## Como as regras de verificação seriam representadas?

Hoje, os checklists deste notebook são Markdown com checkboxes, mantidos manualmente. Se o `cmcli` tiver regras próprias, é preciso decidir o formato (YAML, JSON, ou algo mais próximo do código), se elas acompanham a versão da documentação ou têm um ciclo de release separado, e quem assume a responsabilidade de atualizá-las quando uma dependência muda de versão (por exemplo, quando o Longhorn sai da 1.12 para a 1.13 e um campo de status muda de nome). A proposta de trabalho é manter as regras como YAML em `src/cmcli/checks/`, ao lado dos arquivos Markdown correspondentes, processadas em tempo de build ou em tempo de execução.

## Como evitar que a CLI esconda os comandos reais?

O risco central é o operador rodar `cmcli check k3s`, tratar isso como "a forma certa" de verificar o cluster, e nunca aprender o `kubectl get nodes` equivalente por trás. A mitigação proposta é que cada verificação sempre mostre o comando subjacente que executou (por exemplo, "→ executando: `kubectl get nodes`") e que cada saída aponte para a página correspondente da documentação. A documentação continuaria sendo a fonte de verdade; a CLI seria um atalho sobre ela, não uma camada que a esconde.

## Como testar verificações sem modificar hosts reais?

Uma verificação como `cmcli check firewall` precisa ler `/etc/ufw/` ou consultar `firewall-cmd`, e nenhum dos dois existe dentro de um container de CI comum. As opções em consideração são: testar só em container com dados simulados, aceitando que a documentação (não o teste automatizado) continua sendo a fonte de verdade sobre o comportamento real; testar em VMs reais, mais lento mas mais fiel; ou testar em CI com um container que emula a estrutura de arquivos esperada. Nenhuma das três resolve o problema sozinha, e a escolha final depende de quanto esforço de manutenção de infraestrutura de teste a investigação está disposta a aceitar.

## Quais comandos são só leitura e quais podem modificar o sistema?

O escopo inicial cobre apenas comandos de leitura: `check *` para diagnóstico, `report` para saída estruturada e `help` para documentação embutida. Comandos que modificam o sistema, como um hipotético `apply` para aplicar remediação automática ou `configure` para ajustar configurações, ficam deliberadamente fora de escopo por enquanto. Manter essa linha clara evita que o projeto escorregue de "CLI de diagnóstico" para "ferramenta de configuração", que é um problema de design bem diferente e mais arriscado.

## Como tratar firewalls e distribuições diferentes?

UFW (comum em Ubuntu), firewalld (comum em distribuições baseadas em RHEL) e nftables nativo têm arquivos de configuração, comandos de consulta e modelos conceituais diferentes (regras versus zonas, por exemplo). Como este notebook cobre apenas Debian/Ubuntu, mesmo que o K3s em si seja agnóstico quanto à distribuição, a proposta é limitar o `cmcli` ao mesmo escopo do restante do notebook por enquanto, em vez de tentar suportar todas as combinações desde a primeira versão.

## O relatório pode omitir segredos?

Um `cmcli report` geraria um JSON ou YAML de diagnóstico. Versões, contagem de nós e portas abertas são dados razoáveis de incluir; tokens de API e o conteúdo de arquivos como `/etc/openbao/openbao.hcl` nunca deveriam aparecer. O tratamento de IP do host e hostname ainda é uma questão em aberto, sem resposta definida. A regra de trabalho até agora é nunca incluir nada que seria sensível se aparecesse em `sshd_config`, no `kubeconfig` administrativo ou em uma chave privada de certificado.

## Como apontar para a página correspondente da documentação?

A ideia é que cada verificação, ao falhar, sugira a página relevante do notebook:

```text
cmcli check firewall
Porta 6443: ALLOW (ok)
Porta 2379: CLOSED (esperado se o etcd for externo)
  -> ver: https://site/guides/blueprints/k3s-multinode/#network-requirements
```

Isso exige manter um mapeamento entre cada verificação e a URL correspondente, garantir que essas URLs não mudem sem coordenação (ou que existam redirecionamentos), e aceitar que a documentação pode mudar de estrutura sem que isso quebre silenciosamente a CLI.

## MVP e critério de decisão

Se a investigação avançar, a versão mínima proposta seria: implementar de três a cinco verificações básicas (host, K3s, firewall); produzir saída estruturada em JSON além do formato legível por humanos; mostrar sempre o comando subjacente de cada verificação; não incluir nenhuma modificação do sistema, só leitura; e publicar o resultado como uma página nova (`project/experiments/cmcli-v0.md`) com os resultados reais dos testes, em vez de decidir a adoção apenas com base nesta investigação teórica.

O critério de decisão proposto é objetivo: se `cmcli check k3s` rodar em um ou dois segundos e adicionar mais de 20% de valor percebido em relação a rodar os três ou quatro comandos manuais equivalentes, a ferramenta se justifica. Se o resultado for apenas replicar o que `kubectl get nodes` já faz sozinho, a complexidade adicional não se paga.

## Referências

- Ferramentas que inspiram o formato: `k9s` (TUI completa, veja [ferramentas de gerenciamento visual](../../toolbox/tools/host-management/visual-management/)), `kubectx` (descoberta rápida de contexto), `dive` (análise de camadas de imagem).
