---
title: Service mesh, Istio e Linkerd
sidebar:
  order: 6
---

> **Para quem é:** operadores de clusters já maduros avaliando se comunicação entre serviços precisa de uma camada dedicada de roteamento, segurança e observabilidade.

Um service mesh é uma camada de infraestrutura que intercepta a comunicação entre serviços dentro do cluster para aplicar, de forma uniforme e sem alterar código de aplicação, funções como criptografia em trânsito, retries, controle de tráfego e coleta de métricas. Istio e Linkerd são as duas implementações mais usadas, e cada uma resolve esse mesmo problema com um custo operacional bem diferente.

## O problema que um mesh resolve

Sem service mesh, cada aplicação que precisa de retries automáticos em falhas transitórias, de circuit breakers para evitar sobrecarregar um serviço já degradado, de mutual TLS entre Pods, ou de métricas padronizadas de latência e taxa de erro por chamada, precisa implementar isso na própria aplicação, ou depender de bibliotecas específicas de linguagem que fazem esse trabalho. Em um cluster com múltiplas linguagens e times, isso significa reimplementar a mesma lógica várias vezes, com resultados inconsistentes entre serviços.

Um service mesh resolve isso injetando um proxy (sidecar) ao lado de cada Pod participante. Todo o tráfego de rede do Pod passa por esse proxy antes de sair ou depois de entrar, o que permite ao mesh aplicar políticas de forma transparente: a aplicação continua fazendo chamadas HTTP ou gRPC normais, sem saber que está sendo interceptada.

```mermaid
flowchart LR
    accTitle: Comunicação entre Pods com sidecar de service mesh
    accDescr: Cada Pod tem um proxy sidecar que intercepta todo tráfego de entrada e saída, aplicando mTLS, retries e coleta de métricas antes de encaminhar ao container da aplicação.

    AppA["Container A"] --> SidecarA["Sidecar proxy"]
    SidecarA -->|"mTLS"| SidecarB["Sidecar proxy"]
    SidecarB --> AppB["Container B"]
```

## Istio: recursos amplos, operação mais pesada

Istio cobre roteamento avançado de camada 7 (por header HTTP, por path, por peso de tráfego para deployments canary), mutual TLS automático entre todos os Pods do mesh, circuit breakers, rate limiting, e observabilidade completa de traces e métricas por padrão. Ele também suporta federação entre múltiplos clusters, útil quando serviços estão distribuídos geograficamente ou entre ambientes.

Esse escopo tem um custo: a instalação padrão do Istio adiciona uma dezena de componentes de controle além dos sidecars, configurados através de recursos customizados como `VirtualService` e `DestinationRule`. Entender a interação entre esses recursos exige investimento real de aprendizado antes da primeira configuração em produção, e o consumo de recursos do control plane é proporcionalmente maior que o de alternativas mais enxutas.

Instalação mínima via `istioctl`:

```bash
istioctl install --set profile=demo -y
kubectl label namespace default istio-injection=enabled
```

O rótulo `istio-injection=enabled` no namespace faz o Istio injetar automaticamente o sidecar em todo Pod criado ali a partir desse ponto; Pods já em execução precisam ser recriados para receber o sidecar.

## Linkerd: escopo menor, instalação mais simples

Linkerd cobre o mesmo núcleo essencial (mutual TLS automático, retries e timeouts configuráveis, métricas de latência e erro, controle de acesso por política) com uma superfície de configuração deliberadamente menor: onde Istio expõe recursos customizados extensos, Linkerd resolve a maior parte dos casos comuns com anotações simples no manifest do workload. Não oferece roteamento HTTP de camada 7 tão sofisticado quanto o do Istio (sem match por header arbitrário ou canary por peso configurável no mesmo nível de detalhe), e sua federação multi-cluster é mais recente e menos testada em produção do que a do Istio.

Instalação via Helm:

```bash
helm install linkerd2 linkerd/linkerd2 -n linkerd --create-namespace
kubectl annotate namespace default linkerd.io/inject=enabled
```

A anotação `linkerd.io/inject=enabled` tem o mesmo efeito do rótulo de injeção do Istio: workloads criados no namespace anotado recebem o sidecar automaticamente.

## Decidindo entre os dois

A escolha depende do tamanho do cluster e da complexidade de roteamento necessária, não de qual projeto tem mais recursos no papel. Istio se justifica em clusters com muitos serviços (a partir de algumas dezenas), quando roteamento avançado (canary, A/B testing por header) é um requisito real, quando existe uma equipe com capacidade de operar a complexidade adicional, ou quando multi-cluster é necessário. Linkerd se justifica quando o objetivo é adotar as garantias básicas de um mesh (mTLS, retries, métricas) sem o investimento operacional do Istio, em clusters de porte médio, ou quando a equipe está adotando service mesh pela primeira vez e prefere validar o valor antes de assumir a complexidade máxima da categoria.

Nenhum dos dois se justifica em clusters pequenos (poucas dezenas de serviços ou menos) sem necessidade real de roteamento avançado ou observabilidade centralizada: o overhead de sidecars, tanto em recursos quanto em latência por hop adicional, supera o benefício quando a comunicação entre serviços já é simples e direta.

## Alternativa sem sidecars

O Cilium, além de atuar como CNI (veja [Cilium ou Calico](./cilium-vs-calico/)), implementa parte das funcionalidades de um service mesh diretamente via eBPF, sem exigir um proxy sidecar por Pod. Isso elimina o overhead de latência e memória associado aos sidecars, mas cobre um subconjunto menor de recursos do que Istio ou Linkerd oferecem em conjunto, e é uma abordagem mais recente, com menos tempo de maturação em produção do que qualquer um dos dois meshes tradicionais.

## Páginas relacionadas

- [Cilium ou Calico como CNI](./cilium-vs-calico/)
- [Reverse proxy, fundamentos](./reverse-proxy-basics/)

## Referências

- [Istio (documentação oficial)](https://istio.io/latest/docs/): guia completo de arquitetura, instalação e configuração.
- [Linkerd (documentação oficial)](https://linkerd.io/2/reference/): guia completo de arquitetura, instalação e configuração.
- [Service Mesh Landscape (Layer5)](https://layer5.io/service-mesh-landscape): panorama comparativo de implementações de service mesh.
