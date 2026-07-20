# Progresso da revisão editorial

Rastreamento da aplicação do guia [EDITORIAL.md](./EDITORIAL.md) em todas as páginas de `src/content/docs/`.

## Protocolo de trabalho

1. Leia `EDITORIAL.md` por completo antes de editar qualquer página.
2. Trabalhe um lote por vez: escolha a próxima seção com itens não marcados, na ordem deste arquivo.
3. Para cada página: leia o arquivo inteiro, reescreva conforme o guia, marque `[x]` aqui.
4. Registre pendências técnicas na seção "Pendências" no final deste arquivo, com o caminho do arquivo e a dúvida objetiva.
5. Ao final do lote, pare e apresente o resumo das mudanças. Não faça commit sem autorização explícita.
6. Validação por lote: `./jail-exec.sh bun run build` deve passar antes de considerar o lote pronto.

Regras do repositório: nunca execute comandos no host, use `./jail-exec.sh`; zero comentários em código; componentes como ScriptHelper/FileWriter só funcionam em `.mdx` (em `.md` somem silenciosamente, não os introduza em `.md`).

## Páginas

### contributing
- [x] src/content/docs/contributing/adding-content.md
- [x] src/content/docs/contributing/documentation-style.md
- [x] src/content/docs/contributing/local-development.md
- [x] src/content/docs/contributing/testing-content.md

### getting-started
- [x] src/content/docs/getting-started/create-a-k3s-cluster.md
- [x] src/content/docs/getting-started/planning.md

### guides/blueprints/dns-and-reverse-proxy
- [x] src/content/docs/guides/blueprints/dns-and-reverse-proxy/index.mdx

### guides/blueprints/docker-swarm
- [ ] src/content/docs/guides/blueprints/docker-swarm/application-deployment.md
- [ ] src/content/docs/guides/blueprints/docker-swarm/architecture.md
- [ ] src/content/docs/guides/blueprints/docker-swarm/backup-and-recovery.md
- [ ] src/content/docs/guides/blueprints/docker-swarm/index.md
- [ ] src/content/docs/guides/blueprints/docker-swarm/managers-and-workers.md
- [ ] src/content/docs/guides/blueprints/docker-swarm/networking.md
- [ ] src/content/docs/guides/blueprints/docker-swarm/persistent-data.md
- [ ] src/content/docs/guides/blueprints/docker-swarm/secrets-and-configs.md
- [ ] src/content/docs/guides/blueprints/docker-swarm/updates-and-rollbacks.md

### guides/blueprints/k3s-multinode
- [ ] src/content/docs/guides/blueprints/k3s-multinode/additional-servers.mdx
- [ ] src/content/docs/guides/blueprints/k3s-multinode/agents.mdx
- [ ] src/content/docs/guides/blueprints/k3s-multinode/api-endpoint.mdx
- [ ] src/content/docs/guides/blueprints/k3s-multinode/architecture.mdx
- [ ] src/content/docs/guides/blueprints/k3s-multinode/failure-and-recovery.mdx
- [ ] src/content/docs/guides/blueprints/k3s-multinode/first-server.mdx
- [ ] src/content/docs/guides/blueprints/k3s-multinode/index.mdx
- [ ] src/content/docs/guides/blueprints/k3s-multinode/network-requirements.mdx
- [ ] src/content/docs/guides/blueprints/k3s-multinode/node-maintenance.mdx
- [ ] src/content/docs/guides/blueprints/k3s-multinode/topologies.mdx
- [ ] src/content/docs/guides/blueprints/k3s-multinode/validation.mdx

### guides/blueprints/k3s-single-node-gitops
- [ ] src/content/docs/guides/blueprints/k3s-single-node-gitops/architecture.md
- [ ] src/content/docs/guides/blueprints/k3s-single-node-gitops/backup-and-recovery.md
- [ ] src/content/docs/guides/blueprints/k3s-single-node-gitops/implementation.md
- [ ] src/content/docs/guides/blueprints/k3s-single-node-gitops/index.md
- [ ] src/content/docs/guides/blueprints/k3s-single-node-gitops/limitations.md
- [ ] src/content/docs/guides/blueprints/k3s-single-node-gitops/operations.md
- [ ] src/content/docs/guides/blueprints/k3s-single-node-gitops/prerequisites.md
- [ ] src/content/docs/guides/blueprints/k3s-single-node-gitops/templates.md
- [ ] src/content/docs/guides/blueprints/k3s-single-node-gitops/validation.md
- [ ] src/content/docs/guides/blueprints/k3s-single-node-gitops/variables.md

### guides/tasks/backup
- [ ] src/content/docs/guides/tasks/backup/install-velero.md
- [ ] src/content/docs/guides/tasks/backup/velero-complete-setup.md

### guides/tasks/certificates
- [ ] src/content/docs/guides/tasks/certificates/create-acme-clusterissuer.md
- [ ] src/content/docs/guides/tasks/certificates/install-cert-manager.mdx

### guides/tasks/databases
- [ ] src/content/docs/guides/tasks/databases/access-postgresql-with-gui-client.md
- [ ] src/content/docs/guides/tasks/databases/configure-application-credentials.md
- [ ] src/content/docs/guides/tasks/databases/configure-postgresql-backups.md
- [ ] src/content/docs/guides/tasks/databases/create-postgresql-cluster.md
- [ ] src/content/docs/guides/tasks/databases/expose-postgresql-for-administration.md
- [ ] src/content/docs/guides/tasks/databases/install-cloudnative-pg-operator.md
- [ ] src/content/docs/guides/tasks/databases/restore-postgresql-cluster.md

### guides/tasks/gitops
- [ ] src/content/docs/guides/tasks/gitops/access-argocd.md
- [ ] src/content/docs/guides/tasks/gitops/bootstrap-gitops.mdx
- [ ] src/content/docs/guides/tasks/gitops/connect-git-repository.md
- [ ] src/content/docs/guides/tasks/gitops/create-root-application.md
- [ ] src/content/docs/guides/tasks/gitops/install-argocd.mdx
- [ ] src/content/docs/guides/tasks/gitops/structure-gitops-repository.md

### guides/tasks/host
- [ ] src/content/docs/guides/tasks/host/configure-automatic-security-updates.md
- [ ] src/content/docs/guides/tasks/host/configure-dns.md
- [ ] src/content/docs/guides/tasks/host/configure-fail2ban.md
- [ ] src/content/docs/guides/tasks/host/configure-firewalld.md
- [ ] src/content/docs/guides/tasks/host/configure-hostname.md
- [ ] src/content/docs/guides/tasks/host/configure-persistent-journal.md
- [ ] src/content/docs/guides/tasks/host/configure-time-synchronization.md
- [ ] src/content/docs/guides/tasks/host/configure-ufw.mdx
- [ ] src/content/docs/guides/tasks/host/disable-unnecessary-services.md
- [ ] src/content/docs/guides/tasks/host/harden-ssh.mdx
- [ ] src/content/docs/guides/tasks/host/prepare-debian-server.md
- [ ] src/content/docs/guides/tasks/host/validate-host-requirements.md

### guides/tasks/kubernetes
- [ ] src/content/docs/guides/tasks/kubernetes/configure-k3s-firewall-rules.mdx
- [ ] src/content/docs/guides/tasks/kubernetes/configure-k3s-server-options.md
- [ ] src/content/docs/guides/tasks/kubernetes/configure-kubeconfig.md
- [ ] src/content/docs/guides/tasks/kubernetes/configure-rbac.mdx
- [ ] src/content/docs/guides/tasks/kubernetes/configure-tls-san.md
- [ ] src/content/docs/guides/tasks/kubernetes/install-first-k3s-server.mdx
- [ ] src/content/docs/guides/tasks/kubernetes/join-k3s-agent.mdx
- [ ] src/content/docs/guides/tasks/kubernetes/join-k3s-server.mdx
- [ ] src/content/docs/guides/tasks/kubernetes/remove-k3s-node.md
- [ ] src/content/docs/guides/tasks/kubernetes/uninstall-k3s.md
- [ ] src/content/docs/guides/tasks/kubernetes/validate-k3s-cluster.md

### guides/tasks/networking
- [ ] src/content/docs/guides/tasks/networking/configure-network-policies.mdx
- [ ] src/content/docs/guides/tasks/networking/configure-traefik-gateway-api.mdx
- [ ] src/content/docs/guides/tasks/networking/coredns-local-reverse-proxy.md
- [ ] src/content/docs/guides/tasks/networking/setup-coredns-internal.mdx
- [ ] src/content/docs/guides/tasks/networking/setup-reverse-proxy-localhost.mdx

### guides/tasks/observability
- [ ] src/content/docs/guides/tasks/observability/collect-logs-with-alloy.md
- [ ] src/content/docs/guides/tasks/observability/configure-alertmanager.md
- [ ] src/content/docs/guides/tasks/observability/configure-external-availability-monitoring.md
- [ ] src/content/docs/guides/tasks/observability/configure-pod-monitor.md
- [ ] src/content/docs/guides/tasks/observability/configure-service-monitor.md
- [ ] src/content/docs/guides/tasks/observability/expose-traefik-metrics.md
- [ ] src/content/docs/guides/tasks/observability/install-loki.md
- [ ] src/content/docs/guides/tasks/observability/install-prometheus-stack.md
- [ ] src/content/docs/guides/tasks/observability/monitor-cloudnative-pg.md
- [ ] src/content/docs/guides/tasks/observability/monitor-k3s-nodes.md
- [ ] src/content/docs/guides/tasks/observability/monitor-longhorn.md

### guides/tasks/secrets
- [ ] src/content/docs/guides/tasks/secrets/bootstrap-secret-management.mdx
- [ ] src/content/docs/guides/tasks/secrets/configure-cloudflare-token.mdx
- [ ] src/content/docs/guides/tasks/secrets/configure-openbao-auto-unseal.mdx
- [ ] src/content/docs/guides/tasks/secrets/configure-openbao-high-availability.mdx
- [ ] src/content/docs/guides/tasks/secrets/configure-sops-with-age.mdx
- [ ] src/content/docs/guides/tasks/secrets/create-kubernetes-secret.mdx
- [ ] src/content/docs/guides/tasks/secrets/install-external-secrets-operator.mdx
- [ ] src/content/docs/guides/tasks/secrets/install-infisical.mdx
- [ ] src/content/docs/guides/tasks/secrets/install-openbao.mdx
- [ ] src/content/docs/guides/tasks/secrets/install-sealed-secrets.mdx
- [ ] src/content/docs/guides/tasks/secrets/openbao-advanced-ha.md
- [ ] src/content/docs/guides/tasks/secrets/rotate-application-secret.mdx
- [ ] src/content/docs/guides/tasks/secrets/use-sops-with-argocd.mdx

### guides/tasks/storage
- [ ] src/content/docs/guides/tasks/storage/configure-longhorn-node.md
- [ ] src/content/docs/guides/tasks/storage/configure-volume-backup.md
- [ ] src/content/docs/guides/tasks/storage/create-filesystem-and-mount.md
- [ ] src/content/docs/guides/tasks/storage/create-storage-class.md
- [ ] src/content/docs/guides/tasks/storage/expand-persistent-volume.md
- [ ] src/content/docs/guides/tasks/storage/install-longhorn.mdx
- [ ] src/content/docs/guides/tasks/storage/prepare-host-disk.md
- [ ] src/content/docs/guides/tasks/storage/restore-volume-backup.md

### (raiz)
- [ ] src/content/docs/index.mdx

### learn/backups
- [ ] src/content/docs/learn/backups/backup-fundamentals.md
- [ ] src/content/docs/learn/backups/cluster-state-vs-application-data.md
- [ ] src/content/docs/learn/backups/off-cluster-backups.md
- [ ] src/content/docs/learn/backups/restore-testing.md
- [ ] src/content/docs/learn/backups/retention-strategies.md
- [ ] src/content/docs/learn/backups/rpo-and-rto.md

### learn/backup
- [ ] src/content/docs/learn/backup/velero-overview.md

### learn/clusters
- [ ] src/content/docs/learn/clusters/advanced-ha.md
- [ ] src/content/docs/learn/clusters/docker-compose-vs-swarm-vs-kubernetes.md
- [ ] src/content/docs/learn/clusters/docker-swarm-vs-kubernetes.md
- [ ] src/content/docs/learn/clusters/eks-overview.md
- [ ] src/content/docs/learn/clusters/embedded-vs-external-datastore.mdx
- [ ] src/content/docs/learn/clusters/k3s-architecture.mdx
- [ ] src/content/docs/learn/clusters/kine-overview.md
- [ ] src/content/docs/learn/clusters/kubernetes-distributions.md
- [ ] src/content/docs/learn/clusters/kubernetes.mdx
- [ ] src/content/docs/learn/clusters/managed-vs-selfhosted.md
- [ ] src/content/docs/learn/clusters/quorum.mdx
- [ ] src/content/docs/learn/clusters/rke2-vs-k3s.md

### learn/containers
- [ ] src/content/docs/learn/containers/image-lifecycle.md

### learn/infrastructure
- [ ] src/content/docs/learn/infrastructure/iac-overview.md

### learn/networking
- [ ] src/content/docs/learn/networking/cilium-vs-calico.md

### learn/networking/firewalls
- [ ] src/content/docs/learn/networking/firewalls/docker-published-ports.mdx
- [ ] src/content/docs/learn/networking/firewalls/firewalld.mdx
- [ ] src/content/docs/learn/networking/firewalls/linux-firewall-fundamentals.mdx
- [ ] src/content/docs/learn/networking/firewalls/ufw.mdx
- [ ] src/content/docs/learn/networking/firewalls/ufw-vs-firewalld.mdx

### learn/networking
- [ ] src/content/docs/learn/networking/reverse-proxy-basics.mdx
- [ ] src/content/docs/learn/networking/service-mesh-overview.md
- [ ] src/content/docs/learn/networking/split-horizon-dns.mdx

### learn/observability
- [ ] src/content/docs/learn/observability/alerting.md
- [ ] src/content/docs/learn/observability/application-health.md
- [ ] src/content/docs/learn/observability/blackbox-vs-whitebox-monitoring.md
- [ ] src/content/docs/learn/observability/distributed-tracing.md
- [ ] src/content/docs/learn/observability/logs-and-metrics.md
- [ ] src/content/docs/learn/observability/metrics-logs-and-traces.md
- [ ] src/content/docs/learn/observability/observability-for-small-clusters.md
- [ ] src/content/docs/learn/observability/prometheus-architecture.md
- [ ] src/content/docs/learn/observability/retention.md

### learn/secrets-management
- [ ] src/content/docs/learn/secrets-management/bootstrap-problem.mdx
- [ ] src/content/docs/learn/secrets-management/encryption-vs-secret-store.mdx
- [ ] src/content/docs/learn/secrets-management/external-secrets.mdx
- [ ] src/content/docs/learn/secrets-management/openbao-and-vault.mdx
- [ ] src/content/docs/learn/secrets-management/openbao-auto-unseal.mdx
- [ ] src/content/docs/learn/secrets-management/openbao-high-availability.mdx
- [ ] src/content/docs/learn/secrets-management/overview.mdx
- [ ] src/content/docs/learn/secrets-management/recovery-strategies.mdx
- [ ] src/content/docs/learn/secrets-management/secret-rotation.mdx
- [ ] src/content/docs/learn/secrets-management/secrets-in-git.mdx
- [ ] src/content/docs/learn/secrets-management/sops-vs-sealed-secrets.mdx

### learn/security
- [ ] src/content/docs/learn/security/policy-enforcement.md

### learn/storage
- [ ] src/content/docs/learn/storage/database-storage.md
- [ ] src/content/docs/learn/storage/kubernetes-storage-model.md
- [ ] src/content/docs/learn/storage/local-vs-distributed-storage.md
- [ ] src/content/docs/learn/storage/longhorn-overview.md
- [ ] src/content/docs/learn/storage/persistent-volumes.md
- [ ] src/content/docs/learn/storage/replication-is-not-backup.md

### learn/tools
- [ ] src/content/docs/learn/tools/visual-management.md

### operations/backups
- [ ] src/content/docs/operations/backups/backup-and-recovery.md
- [ ] src/content/docs/operations/backups/backup-gitops-bootstrap-data.md
- [ ] src/content/docs/operations/backups/backup-k3s-etcd.md
- [ ] src/content/docs/operations/backups/backup-kubernetes-resources.md
- [ ] src/content/docs/operations/backups/backup-longhorn-volumes.md
- [ ] src/content/docs/operations/backups/backup-postgresql.md
- [ ] src/content/docs/operations/backups/protect-age-keys.md
- [ ] src/content/docs/operations/backups/setup-velero-backups.md
- [ ] src/content/docs/operations/backups/validate-backups.md

### operations/checklists
- [ ] src/content/docs/operations/checklists/application-readiness.md
- [ ] src/content/docs/operations/checklists/automated-validation.md
- [ ] src/content/docs/operations/checklists/backup-readiness.md
- [ ] src/content/docs/operations/checklists/cluster-operational-checklist.md
- [ ] src/content/docs/operations/checklists/cluster-security.md
- [ ] src/content/docs/operations/checklists/disaster-recovery-readiness.md
- [ ] src/content/docs/operations/checklists/host-security.md
- [ ] src/content/docs/operations/checklists/observability-readiness.md
- [ ] src/content/docs/operations/checklists/post-install-checklist.md
- [ ] src/content/docs/operations/checklists/production-readiness.md
- [ ] src/content/docs/operations/checklists/upgrade-readiness.md

### operations/disaster-recovery
- [ ] src/content/docs/operations/disaster-recovery/multinode-scenarios.mdx
- [ ] src/content/docs/operations/disaster-recovery/rebuild-single-node-cluster.mdx
- [ ] src/content/docs/operations/disaster-recovery/recover-secret-management.mdx
- [ ] src/content/docs/operations/disaster-recovery/restore-k3s-etcd.mdx
- [ ] src/content/docs/operations/disaster-recovery/restore-longhorn-volume.mdx
- [ ] src/content/docs/operations/disaster-recovery/restore-postgresql.mdx

### operations/maintenance
- [ ] src/content/docs/operations/maintenance/certificate-review.md
- [ ] src/content/docs/operations/maintenance/disk-capacity-review.md
- [ ] src/content/docs/operations/maintenance/drain-and-uncordon-node.md
- [ ] src/content/docs/operations/maintenance/k3s-cluster-maintenance.md
- [ ] src/content/docs/operations/maintenance/maintenance-runbook.md
- [ ] src/content/docs/operations/maintenance/node-maintenance.md

### operations/observability
- [ ] src/content/docs/operations/observability/observability-and-alerting.md

### operations/troubleshooting
- [ ] src/content/docs/operations/troubleshooting/argocd-out-of-sync.md
- [ ] src/content/docs/operations/troubleshooting/certificate-not-ready.md
- [ ] src/content/docs/operations/troubleshooting/node-not-ready.md
- [ ] src/content/docs/operations/troubleshooting/pod-pending.md

### operations/upgrades
- [ ] src/content/docs/operations/upgrades/upgrade-k3s-multinode.mdx
- [ ] src/content/docs/operations/upgrades/upgrade-k3s-single-node.mdx

### project
- [ ] src/content/docs/project/content-policy.md
- [ ] src/content/docs/project/decisions.md
- [ ] src/content/docs/project/disclaimer.md

### project/experiments
- [ ] src/content/docs/project/experiments/cmcli.md

### project
- [ ] src/content/docs/project/scope.md

### reference
- [ ] src/content/docs/reference/conventions.md

### resources
- [ ] src/content/docs/resources/index.md

### technologies
- [ ] src/content/docs/technologies/index.md

### toolbox/commands
- [ ] src/content/docs/toolbox/commands/certificates.md
- [ ] src/content/docs/toolbox/commands/containers.md
- [ ] src/content/docs/toolbox/commands/dns.md
- [ ] src/content/docs/toolbox/commands/filesystems.md
- [ ] src/content/docs/toolbox/commands/git.md
- [ ] src/content/docs/toolbox/commands/index.md
- [ ] src/content/docs/toolbox/commands/kubernetes.md
- [ ] src/content/docs/toolbox/commands/networking.md
- [ ] src/content/docs/toolbox/commands/processes.md
- [ ] src/content/docs/toolbox/commands/random-values.md
- [ ] src/content/docs/toolbox/commands/systemd.md
- [ ] src/content/docs/toolbox/commands/troubleshooting.md

### toolbox/snippets
- [ ] src/content/docs/toolbox/snippets/bash.md
- [ ] src/content/docs/toolbox/snippets/docker-compose.md
- [ ] src/content/docs/toolbox/snippets/index.md
- [ ] src/content/docs/toolbox/snippets/kubernetes.md

### toolbox/tools/automation
- [ ] src/content/docs/toolbox/tools/automation/index.md

### toolbox/tools/container-management
- [ ] src/content/docs/toolbox/tools/container-management/index.md

### toolbox/tools/database-clients
- [ ] src/content/docs/toolbox/tools/database-clients/db-tools.md
- [ ] src/content/docs/toolbox/tools/database-clients/index.md

### toolbox/tools/file-explorers
- [ ] src/content/docs/toolbox/tools/file-explorers/index.md

### toolbox/tools/file-transfer
- [ ] src/content/docs/toolbox/tools/file-transfer/index.md
- [ ] src/content/docs/toolbox/tools/file-transfer/transfer-tools.md

### toolbox/tools/host-management
- [ ] src/content/docs/toolbox/tools/host-management/cluster-tools.md
- [ ] src/content/docs/toolbox/tools/host-management/index.md

### toolbox/tools/kubernetes-management
- [ ] src/content/docs/toolbox/tools/kubernetes-management/command-line-tools.mdx

### toolbox/tools/networking
- [ ] src/content/docs/toolbox/tools/networking/index.md

### toolbox/tools/observability
- [ ] src/content/docs/toolbox/tools/observability/index.md

### toolbox/tools
- [ ] src/content/docs/toolbox/tools/overview.md

### toolbox/tools/remote-access
- [ ] src/content/docs/toolbox/tools/remote-access/index.md
- [ ] src/content/docs/toolbox/tools/remote-access/ssh-clients.md

### toolbox/tools/security
- [ ] src/content/docs/toolbox/tools/security/index.md

### toolbox/tools/troubleshooting
- [ ] src/content/docs/toolbox/tools/troubleshooting/index.md

## Pendências

- `src/content/docs/guides/tasks/networking/setup-coredns-internal.mdx` e
  `setup-reverse-proxy-localhost.mdx` (seção "Próximo passo" de ambos): linkam para
  `../validate-dns-and-proxy/`, uma página que não existe em `guides/tasks/networking/`. O
  blueprint `dns-and-reverse-proxy/index.mdx` foi ajustado para não referenciar essa página
  (aponta para os passos de validação já embutidos em cada guia). Ao revisar o lote
  `guides/tasks/networking`, decidir entre criar a página de validação ou remover esses dois
  links quebrados.
- `src/content/docs/guides/blueprints/k3s-multinode/index.mdx` (seção "Reaproveitamento da Fase
  2"): os três links relativos para `guides/tasks/...` usam um nível a mais de `../`
  (`../../../tasks/...`), o que resolve para `/tasks/...` em vez de `/guides/tasks/...` (link
  quebrado). Mesma classe de bug corrigida neste lote em `dns-and-reverse-proxy/index.mdx`;
  corrigir quando esse arquivo for revisado.
