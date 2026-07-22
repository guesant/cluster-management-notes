---
title: Blogs de engenharia
description: Catálogo curado de blogs de engenharia relevantes para infraestrutura, cloud native e operação de sistemas em produção, com modelo fixo por entrada e data de última verificação, para evitar que a lista apodreça.
sidebar:
  order: 8
---

> **Para quem é:** quem já opera o que este notebook ensina e quer acompanhar como outras organizações resolvem problemas parecidos em produção real.

## O modelo e o critério de inclusão

Cada entrada segue o mesmo conjunto fixo de campos, para que uma lista não vire uma coleção de logotipos sem contexto: **organização**, **URL oficial**, **assuntos recorrentes**, **nível de profundidade** (introdutório, intermediário, avançado), **tipo de material** (post técnico, estudo de caso, anúncio de release), **frequência aproximada** de publicação, **exige assinatura?**, **última verificação** da URL, e **páginas do notebook relacionadas**, quando existir uma ligação real, não forçada.

O critério de inclusão é escrever sobre problemas reais de infraestrutura, não conteúdo de marketing genérico republicado como "engenharia". Um blog entra aqui quando publica com regularidade sobre decisões técnicas concretas (por que uma arquitetura mudou, o que um incidente ensinou, como um sistema específico foi construído), verificável nos próprios posts, não em resumos de terceiros.

## Infraestrutura e cloud native

### Cloudflare Blog

- **URL oficial:** [blog.cloudflare.com](https://blog.cloudflare.com/)
- **Assuntos recorrentes:** infraestrutura de rede em escala global, DNS e DNSSEC, segurança (WAF, mitigação de DDoS, pós-quântica), sistemas distribuídos e consenso, ferramentas para desenvolvedores (Workers).
- **Nível de profundidade:** intermediário a avançado; posts frequentemente incluem detalhes de implementação, não só visão de produto.
- **Tipo de material:** post técnico e post-mortem de incidente.
- **Frequência aproximada:** várias publicações por semana.
- **Exige assinatura?** Não.
- **Última verificação:** 2026-07-22.
- **Páginas relacionadas:** [DNS e registro de domínios](../../learn/networking/dns/), [Túneis de exposição](../../learn/networking/fundamentals/exposure-tunnels/) (Cloudflare Tunnel).

### CNCF Blog

- **URL oficial:** [cncf.io/blog](https://www.cncf.io/blog/)
- **Assuntos recorrentes:** anúncios e graduação de projetos CNCF, casos de uso de usuários finais, platform engineering, IA em cargas de trabalho Kubernetes, cobertura de eventos (KubeCon).
- **Nível de profundidade:** introdutório a intermediário; mistura anúncio de projeto com conteúdo técnico mais aprofundado, dependendo do autor.
- **Tipo de material:** anúncio de projeto, estudo de caso, cobertura de evento.
- **Frequência aproximada:** diária.
- **Exige assinatura?** Não.
- **Última verificação:** 2026-07-22.
- **Páginas relacionadas:** [Trilha CNCF/Linux Foundation](../certifications/kubernetes-cncf/).

### Kubernetes Blog

- **URL oficial:** [kubernetes.io/blog](https://kubernetes.io/blog/)
- **Assuntos recorrentes:** anúncios de release, graduação de features (alpha → beta → GA), avisos de segurança (CVEs), destaques de SIG, guias operacionais oficiais.
- **Nível de profundidade:** intermediário a avançado; é a fonte primária para mudanças reais do projeto, não uma cobertura de terceiros.
- **Tipo de material:** anúncio de release, aprofundamento técnico de feature, aviso de segurança.
- **Frequência aproximada:** semanal, mais frequente perto de um lançamento de versão.
- **Exige assinatura?** Não.
- **Última verificação:** 2026-07-22.
- **Páginas relacionadas:** [Kubernetes](../../learn/clusters/kubernetes/).

### Grafana Labs Blog

- **URL oficial:** [grafana.com/blog](https://grafana.com/blog/)
- **Assuntos recorrentes:** releases de Grafana/Tempo/Loki/Mimir, observabilidade e monitoramento, IA aplicada a análise de causa raiz, revisões de incidentes.
- **Nível de profundidade:** introdutório a intermediário; conteúdo técnico convive com material comparativo/comercial (comparações com Datadog, New Relic).
- **Tipo de material:** anúncio de release, post técnico, revisão de incidente.
- **Frequência aproximada:** várias publicações por semana.
- **Exige assinatura?** Não.
- **Última verificação:** 2026-07-22.
- **Páginas relacionadas:** [Arquitetura do Prometheus](../../learn/observability/prometheus-architecture/), [Logs, métricas e traces](../../learn/observability/metrics-logs-and-traces/).

### LWN.net

- **URL oficial:** [lwn.net](https://lwn.net/)
- **Assuntos recorrentes:** desenvolvimento do kernel Linux, software livre, segurança, distribuições, ferramentas e eventos da comunidade.
- **Nível de profundidade:** avançado; cobertura de discussões reais de listas de e-mail de desenvolvimento do kernel, não resumo superficial.
- **Tipo de material:** reportagem técnica e análise editorial.
- **Frequência aproximada:** semanal (a publicação original é literalmente semanal, "Linux Weekly News").
- **Exige assinatura?** Parcialmente; parte do conteúdo é de acesso livre, parte exige assinatura paga para acesso completo ou imediato (artigos recentes costumam ficar liberados ao público depois de um período).
- **Última verificação:** 2026-07-22.
- **Páginas relacionadas:** [Shells: interativo, login e o que POSIX garante](../../learn/unix/shells/), [POSIX: o que o padrão garante, e o que fica de fora](../../learn/unix/posix-and-standards/).

### Linux Kernel Documentation

- **URL oficial:** [docs.kernel.org](https://docs.kernel.org/)
- **Assuntos recorrentes:** documentação oficial do próprio kernel: APIs internas, subsistemas, administração, guias de arquitetura, processo de contribuição.
- **Nível de profundidade:** avançado; é documentação de referência primária, não material introdutório.
- **Tipo de material:** documentação de referência.
- **Frequência aproximada:** contínua, acompanhando o ciclo de release do kernel.
- **Exige assinatura?** Não.
- **Última verificação:** 2026-07-22.
- **Páginas relacionadas:** [Namespaces do kernel](../../learn/containers/namespaces/), [Cgroups: limites e contabilização de recursos](../../learn/containers/cgroups/).

## Engenharia de produto

Blogs de empresas que operam produtos em escala, cobrindo decisões de arquitetura, infraestrutura e sistemas distribuídos que extrapolam o contexto específico de infraestrutura/cloud native da seção anterior, mas continuam sendo engenharia real de produção, não marketing.

### Engineering at Meta

- **URL oficial:** [engineering.fb.com](https://engineering.fb.com/)
- **Assuntos recorrentes:** infraestrutura de IA em escala, sistemas de armazenamento distribuído, tecnologia de vídeo, segurança/privacidade, hardware (incluindo AR/VR).
- **Nível de profundidade:** avançado; cobre desafios de escala massiva com detalhe técnico real.
- **Tipo de material:** post técnico e anúncio de projeto open source.
- **Frequência aproximada:** várias publicações por semana.
- **Exige assinatura?** Não.
- **Última verificação:** 2026-07-22.
- **Páginas relacionadas:** nenhuma ligação direta e específica identificada nesta verificação.

### Discord Engineering

- **URL oficial:** [discord.com/blog/engineering](https://discord.com/blog/engineering)
- **Assuntos recorrentes:** infraestrutura de voz/edge, operação de bancos de dados distribuídos em escala (ScyllaDB), indexação de mensagens, criptografia ponta a ponta.
- **Nível de profundidade:** avançado; frequentemente detalha decisões de arquitetura e automação de operação.
- **Tipo de material:** post técnico e anúncio de ferramenta open source.
- **Frequência aproximada:** semanal a quinzenal.
- **Exige assinatura?** Não.
- **Última verificação:** 2026-07-22.
- **Páginas relacionadas:** nenhuma ligação direta e específica identificada nesta verificação.

### Netflix TechBlog

- **URL oficial:** [netflixtechblog.com](https://netflixtechblog.com/)
- **Assuntos recorrentes:** arquitetura de sistemas distribuídos, streaming em escala, cultura de engenharia, ciência de dados.
- **Nível de profundidade:** avançado; referência histórica da indústria para engenharia de sistemas em escala (blog ativo desde 2010).
- **Tipo de material:** post técnico e estudo de caso de arquitetura.
- **Frequência aproximada:** semanal.
- **Exige assinatura?** Hospedado no Medium; parte do conteúdo pode exigir login gratuito no Medium para leitura completa, dependendo da política de acesso vigente no momento da leitura.
- **Última verificação:** 2026-07-22.
- **Páginas relacionadas:** nenhuma ligação direta e específica identificada nesta verificação.

### AWS Architecture Blog

- **URL oficial:** [aws.amazon.com/blogs/architecture](https://aws.amazon.com/blogs/architecture/)
- **Assuntos recorrentes:** padrões de arquitetura de referência, compute/serverless, storage e bancos de dados, analytics, estudos de caso de clientes.
- **Nível de profundidade:** intermediário a avançado; mistura padrão de referência genérico com implementação real de cliente.
- **Tipo de material:** padrão de arquitetura e estudo de caso.
- **Frequência aproximada:** várias publicações por semana.
- **Exige assinatura?** Não.
- **Última verificação:** 2026-07-22.
- **Páginas relacionadas:** [Certificações AWS](../certifications/aws/).

### Google Cloud Blog

- **URL oficial:** [cloud.google.com/blog](https://cloud.google.com/blog)
- **Assuntos recorrentes:** IA/ML, containers e Kubernetes, DevOps/SRE, segurança, dados e analytics, por indústria.
- **Nível de profundidade:** introdutório a intermediário; parte do conteúdo é anúncio de produto, parte é aprofundamento técnico de time de engenharia.
- **Tipo de material:** anúncio de produto e post técnico.
- **Frequência aproximada:** diária.
- **Exige assinatura?** Não.
- **Última verificação:** 2026-07-22.
- **Páginas relacionadas:** nenhuma ligação direta e específica identificada nesta verificação.

### Microsoft Dev Blogs

- **URL oficial:** [devblogs.microsoft.com](https://devblogs.microsoft.com/)
- **Assuntos recorrentes:** hub de dezenas de blogs especializados por linguagem/produto (.NET, PowerShell, Azure, Visual Studio Code, DevOps), não um blog único.
- **Nível de profundidade:** varia por sub-blog; de introdutório a avançado.
- **Tipo de material:** post técnico e anúncio de release.
- **Frequência aproximada:** diária, somando todos os sub-blogs.
- **Exige assinatura?** Não.
- **Última verificação:** 2026-07-22.
- **Páginas relacionadas:** [Certificações Azure](../certifications/azure/).

### GitHub Engineering

- **URL oficial:** [github.blog/category/engineering](https://github.blog/category/engineering/)
- **Assuntos recorrentes:** infraestrutura e performance em escala, ferramentas de IA (Copilot), arquitetura de plataforma, segurança de supply chain.
- **Nível de profundidade:** avançado; frequentemente cobre decisões de arquitetura com números reais de escala (milhões de commits, bilhões de requisições).
- **Tipo de material:** post técnico e anúncio de ferramenta.
- **Frequência aproximada:** semanal.
- **Exige assinatura?** Não.
- **Última verificação:** 2026-07-22.
- **Páginas relacionadas:** [Comandos de Git (cookbook)](../../toolbox/commands/git/).

### Uber Engineering

- **URL oficial:** [uber.com/blog/engineering](https://www.uber.com/blog/engineering/)
- **Assuntos recorrentes:** infraestrutura backend, dados, IA/ML, sistemas de recomendação, mobile.
- **Nível de profundidade:** avançado; mais de 700 artigos publicados ao longo dos anos, cobrindo desafios reais de escala.
- **Tipo de material:** post técnico.
- **Frequência aproximada:** semanal.
- **Exige assinatura?** Não.
- **Última verificação:** 2026-07-22.
- **Páginas relacionadas:** nenhuma ligação direta e específica identificada nesta verificação.

### Stripe Engineering Blog

- **URL oficial:** [stripe.dev/blog/topic/engineering](https://stripe.dev/blog/topic/engineering)
- **Assuntos recorrentes:** infraestrutura de pagamentos, migrações de dados em larga escala sem downtime, ferramentas internas de desenvolvimento, agentes de IA para automação de código.
- **Nível de profundidade:** avançado; exemplos concretos como migração de 3,7 milhões de linhas de código numa única mudança.
- **Tipo de material:** post técnico.
- **Frequência aproximada:** semanal a quinzenal.
- **Exige assinatura?** Não.
- **Última verificação:** 2026-07-22.
- **Páginas relacionadas:** nenhuma ligação direta e específica identificada nesta verificação.

### Engineering at Slack

- **URL oficial:** [slack.engineering](https://slack.engineering/)
- **Assuntos recorrentes:** infraestrutura de nuvem multi-cloud, segurança, testes, arquitetura de backend (pipelines de dados, notificações).
- **Nível de profundidade:** avançado; posts frequentemente escritos por engenheiros individuais até nível staff.
- **Tipo de material:** post técnico.
- **Frequência aproximada:** semanal.
- **Exige assinatura?** Não.
- **Última verificação:** 2026-07-22.
- **Páginas relacionadas:** nenhuma ligação direta e específica identificada nesta verificação.

## Como manter este catálogo

Este catálogo apodrece se ninguém o mantiver; três regras simples evitam isso:

- **Quando remover uma fonte:** o blog para de publicar por mais de um ano, muda de propósito (deixa de ser conteúdo técnico e vira só material de marketing), ou a URL para de existir sem redirecionamento para um sucessor claro. Remover é preferível a deixar uma entrada morta com "última verificação" cada vez mais antiga.
- **Como registrar uma verificação:** ao revisitar uma entrada (para adicionar, corrigir ou confirmar), atualize o campo "última verificação" para a data real da revisão, mesmo que nada mais tenha mudado; uma entrada nunca revisitada depois da criação é a que mais provavelmente está desatualizada.
- **Ao adicionar uma entrada nova:** siga o modelo completo de 9 campos desta página, verifique a URL de fato (não assuma que ela continua válida só porque apareceu numa busca), e só adicione um link de "páginas relacionadas" quando a ligação for real, não para preencher o campo.
