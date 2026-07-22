---
title: "Kubescape: modelo mental, não lista de comandos"
description: O que Kubescape analisa (manifests, cluster, imagens), os frameworks que ele avalia (NSA, MITRE, CIS), o que um score significa, como interpretar falsos positivos, por que scanner não é enforcement, e onde entra num pipeline de CI.
sidebar:
  order: 4
---

> **Para quem é:** quem já decidiu qual camada de admission enforcement usar (a página anterior desta trilha) e precisa entender o que uma ferramenta de varredura de postura acrescenta, sem tratá-la como uma lista de flags a decorar.

**Kubescape** varre manifests, um cluster já em execução, ou imagens de container, e reporta violações de postura de segurança contra um conjunto de controles conhecidos. A distinção que importa entender antes de qualquer comando é a mesma que separa diagnóstico de correção: Kubescape identifica o que está fora do esperado, não impede que aconteça. Essa diferença de papel frente ao [policy enforcement](../policy-enforcement/) já coberto na página anterior é o eixo desta página, não uma nota de rodapé.

## O que Kubescape analisa

Kubescape opera sobre três superfícies diferentes, e o que ele encontra depende de qual delas está sendo varrida:

- **Manifests estáticos** (arquivos YAML, um diretório de Helm chart renderizado, ou saída de `kustomize build`): útil antes de aplicar qualquer coisa ao cluster, o ponto mais barato do ciclo para pegar um problema, porque nada chegou a rodar ainda.
- **Cluster em execução**: conecta via `kubeconfig` e varre os recursos já aplicados, incluindo configuração que só existe em runtime (RBAC efetivo, `NetworkPolicy` realmente em vigor), não visível a partir de um manifest isolado.
- **Imagens de container**: varredura de vulnerabilidades na imagem em si, sobreposta em escopo com o que [Trivy](../../../toolbox/tools/security/scanning-tools/#trivy-varredura-de-vulnerabilidades-secrets-e-configuração) já cobre no catálogo de ferramentas deste notebook, não uma capacidade exclusiva do Kubescape.

## Frameworks: o padrão contra o qual cada controle é avaliado

Um controle isolado ("este Pod roda como root") só faz sentido dentro de um framework que declara por que isso importa e com que prioridade. Kubescape avalia contra múltiplos frameworks publicados, dos quais três aparecem com mais frequência em relatórios:

- **NSA/CISA Kubernetes Hardening Guidance**: recomendações de hardening publicadas conjuntamente pela NSA e pela CISA (agência de segurança de infraestrutura dos EUA), cobrindo desde segmentação de rede até auditoria e detecção de ameaças.
- **MITRE ATT&CK for Containers**: framework de táticas e técnicas de ataque adaptado para o contexto de containers e Kubernetes, organizando controles em torno de como um atacante realmente se move dentro de um cluster comprometido, não em torno de uma lista de configurações desejáveis.
- **CIS Kubernetes Benchmark**: o mesmo benchmark que o [kube-bench](../../../toolbox/tools/security/scanning-tools/#kube-bench-verificação-contra-o-cis-kubernetes-benchmark) já executa contra os componentes do control plane; Kubescape cobre uma fatia sobreposta, mas a partir de manifests e do estado do cluster, não só de arquivos de configuração do nó.

Até a escrita, esses três são os frameworks mais citados na documentação oficial do projeto; confira a [documentação de frameworks do Kubescape](https://kubescape.io/docs/frameworks/) para a lista completa e atualizada, que muda conforme novos padrões da indústria são adotados.

## O que um score significa (e o que não significa)

Kubescape resume o resultado de uma varredura como um percentual: a proporção de controles do framework escolhido que passaram, ponderada pela severidade de cada controle, não uma contagem simples de "quantos passaram sobre o total". Um score de 80% não significa "o cluster está 80% seguro" no sentido absoluto; significa "80% do peso ponderado dos controles avaliados por este framework específico passou nesta varredura específica". Comparar o score de dois clusters só faz sentido se os dois foram varridos contra o mesmo framework, com a mesma versão do Kubescape, porque tanto o conjunto de controles quanto os pesos podem mudar entre versões e frameworks.

Tratar o score como uma meta a maximizar sem entender o que cada controle reprovado realmente significa é o uso mais comum e mais equivocado da ferramenta: um score alto obtido silenciando exceções sem justificativa documentada é pior que um score mais baixo com exceções revisadas e registradas, porque o primeiro caso esconde risco real atrás de um número que parece bom.

## Falsos positivos: quando um controle reprovado não é um problema real

Um controle de Kubescape reprova com base em padrões genéricos (um Pod sem `resources.limits` definidos, por exemplo), sem contexto sobre por que aquele workload específico foi configurado daquele jeito. Um job de curta duração que roda uma vez por dia pode não precisar dos mesmos limites de recurso que um serviço de longa duração recebendo tráfego contínuo; um controle genérico não sabe disso. A resposta correta a um falso positivo não é ignorar silenciosamente o resultado; é registrar uma exceção documentada (o próprio Kubescape suporta exceções por recurso ou por controle, com justificativa), de forma que a próxima pessoa a ler o relatório entenda que a reprovação foi avaliada e considerada aceitável, não simplesmente esquecida.

## Scanner não é enforcement

Esta é a distinção central da página, e a razão de contrastar explicitamente com [policy enforcement](../policy-enforcement/): Kubescape roda uma varredura e produz um relatório, mas não intercepta um `kubectl apply` nem impede um manifest inseguro de ser aplicado, ao contrário do Pod Security Admission, Kyverno ou OPA/Gatekeeper, que rodam como admission webhook na etapa de admissão da API. Um cluster pode ter um score de Kubescape excelente num relatório de segunda-feira e, na terça, receber um Deployment que viola vários desses controles sem nenhuma rejeição, porque nada no caminho de admissão consultou o Kubescape antes de aceitar o recurso. Usar Kubescape como se fosse enforcement (rodar a varredura uma vez, ver o score, considerar o problema resolvido) deixa esse intervalo completamente descoberto; usar os dois em conjunto (Kubescape para visibilidade contínua e auditoria, policy enforcement para bloquear na admissão) é o padrão que cobre tanto detecção quanto prevenção.

## Onde entra em CI

O uso mais eficaz de Kubescape não é uma varredura manual ocasional, é integrá-lo ao pipeline que já gera os manifests: rodar `kubescape scan` contra os manifests renderizados (de um Helm chart ou de `kustomize build`) como um step de CI, antes do merge, transforma a varredura na mesma barreira "antes de chegar ao cluster" que testes automatizados já representam para código de aplicação. Falhar o pipeline quando um controle de severidade alta reprova (sem necessariamente falhar por qualquer reprovação, dado o problema de falsos positivos já discutido) é o equilíbrio prático mais comum: barra o que é claramente grave, deixa o resto para revisão humana registrada como exceção.

## kube-no-trouble: um problema vizinho, não o mesmo problema

**kube-no-trouble** (`kubent`) resolve um problema adjacente, mas distinto: em vez de avaliar postura de segurança, ele varre um cluster em busca de recursos que usam versões de API do Kubernetes já removidas ou marcadas para remoção numa versão futura, o tipo de coisa que quebra silenciosamente um upgrade de cluster meses depois de o manifest ter sido escrito. A separação de responsabilidade é limpa: Kubescape pergunta "este recurso está configurado com segurança?"; kube-no-trouble pergunta "este recurso ainda vai existir depois do próximo upgrade?". Rodar os dois antes de um upgrade de versão do Kubernetes (kube-no-trouble para compatibilidade de API, Kubescape para postura) cobre duas classes de risco que nenhuma das duas ferramentas sozinha cobre.

## Páginas relacionadas

- [Policy Enforcement — OPA, Kyverno e Pod Security Admission](../policy-enforcement/): a camada que efetivamente bloqueia na admissão, em vez de só reportar.
- [Ferramentas de varredura e verificação de postura](../../../toolbox/tools/security/scanning-tools/): Trivy e kube-bench, com sobreposição parcial de escopo com Kubescape.

## Referências

- [Kubescape (documentação oficial)](https://kubescape.io/docs/): visão geral, instalação e frameworks suportados.
- [Kubescape: Frameworks](https://kubescape.io/docs/frameworks/): lista de frameworks avaliados (até a escrita; confira a página oficial para o estado atual).
- [NSA/CISA Kubernetes Hardening Guidance](https://www.nsa.gov/Press-Room/Press-Releases-Statements/Press-Release-View/Article/3237482/): documento oficial que origina o framework.
- [MITRE ATT&CK for Containers](https://attack.mitre.org/matrices/enterprise/containers/): matriz oficial de táticas e técnicas.
- [CIS Kubernetes Benchmark (Center for Internet Security)](https://www.cisecurity.org/benchmark/kubernetes): benchmark oficial, mesmo usado pelo kube-bench.
- [kube-no-trouble (kubent) — repositório oficial](https://github.com/doitintl/kube-no-trouble): detecção de APIs Kubernetes deprecadas/removidas antes de um upgrade.
