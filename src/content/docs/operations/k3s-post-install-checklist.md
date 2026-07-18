---
title: Validação pós-instalação do K3s
sidebar:
  order: 5
---

Use este checklist como uma verificação pontual antes de considerar a instalação concluída. Depois do bootstrap, siga o [guia de operação contínua](../../guides/operations-overview/) para manutenção, monitoramento, alertas, atualização de imagens, probes e testes de recuperação.

Os itens do núcleo se aplicam à instalação do K3s. Os blocos marcados como
**quando adotado** só se aplicam quando o respectivo módulo fizer parte da
arquitetura escolhida.

## Núcleo K3s

- [ ] Todos os nós K3s estão `Ready` e possuem nomes únicos.
- [ ] O endpoint estável da API funciona a partir dos nós e da estação administrativa.
- [ ] Um snapshot do etcd foi criado e copiado para fora do cluster.
- [ ] O token do K3s está protegido.
- [ ] O kubeconfig administrativo está protegido.
- [ ] As versões realmente instaladas foram registradas.
- [ ] O procedimento de atualização e recuperação foi testado em homologação.

## Segurança dos hosts (quando adotada)

- [ ] O acesso SSH por chave funciona em uma nova sessão.
- [ ] A autenticação SSH por senha foi rejeitada.
- [ ] UFW e Fail2Ban estão ativos e com regras revisadas.

## Gateway API e NetworkPolicy (quando adotados)

- [ ] Os CRDs da Gateway API existem e o Traefik não registra erros do provider.
- [ ] Os namespaces isolados possuem deny por padrão, DNS funcional e permissões explícitas testadas para cada fluxo necessário.

## [cert-manager](../../kubernetes/extensions/cert-manager/) (quando adotado)

- [ ] O cert-manager possui pods saudáveis.
- [ ] `cmctl check api --wait=2m` confirma os CRDs e o webhook, quando a CLI é adotada.
- [ ] Um `Certificate` de teste emitido pelo tipo de Issuer adotado chegou a `Ready` e criou o Secret esperado sem expor seu conteúdo.

## Longhorn (quando adotado)

- [ ] O Longhorn possui pods saudáveis.
- [ ] O preflight do Longhorn passa em todos os nós de armazenamento.

## Argo CD e GitOps (quando adotados)

- [ ] O Argo CD possui pods saudáveis.
- [ ] A Application `root` e as Applications selecionadas estão sincronizadas e saudáveis no Argo CD.

## Infisical (quando adotado)

- [ ] A Machine Identity do Infisical possui privilégio mínimo, o Secret de bootstrap não está no Git, a rotação foi testada e os recursos de sincronização estão saudáveis.

## Identidades individuais e RBAC (quando adotados)

- [ ] Cada pessoa possui uma identidade individual com validade limitada, RBAC revisado e kubeconfig protegido; o kubeconfig administrativo não é compartilhado.

## Fontes e leitura adicional

- [K3s — Cluster Access](https://docs.k3s.io/cluster-access) — Explica o kubeconfig administrativo, o acesso remoto e os cuidados ao distribuir credenciais do cluster.
- [K3s — Backup and Restore](https://docs.k3s.io/datastore/backup-restore) — Define os artefatos necessários para recuperar cada tipo de datastore, incluindo o token do servidor.
- [K3s — Token Management](https://docs.k3s.io/cli/token) — Detalha os privilégios dos tokens, sua rotação e sua relação com a restauração de snapshots.
- [K3s — Manual Upgrades](https://docs.k3s.io/upgrades/manual) — Documenta a ordem de atualização dos nós, os canais e as restrições de version skew.
- [K3s — CIS Hardening Guide](https://docs.k3s.io/security/hardening-guide) — Reúne controles de segurança para hosts, componentes Kubernetes, Pod Security, NetworkPolicy e auditoria.
- [Kubernetes — Security Checklist](https://kubernetes.io/docs/concepts/security/security-checklist/) — Checklist oficial complementar para autenticação, autorização, workloads, rede, Secrets e observabilidade.
