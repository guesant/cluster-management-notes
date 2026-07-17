# Checklist operacional

Antes de considerar a instalação concluída:

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

## cert-manager (quando adotado)

- [ ] O cert-manager possui pods saudáveis.

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
