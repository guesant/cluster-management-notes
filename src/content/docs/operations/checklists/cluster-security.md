---
title: Segurança do cluster
sidebar:
  order: 3
---

> **Para quem é:** quem precisa confirmar ou auditar a postura de segurança de um cluster K3s.

Checklist especializado referenciado pelo [checklist central](../cluster-operational-checklist/).

- [ ] RBAC com privilégio mínimo para identidades não administrativas
  - Explicação e configuração: [identidade, autenticação e RBAC](../../../guides/tasks/kubernetes/configure-rbac/)
  - Verificação: `kubectl auth can-i --list --as <identidade>`
  - Frequência: ao criar uma identidade; revisar trimestralmente

- [ ] Kubeconfig administrativo tratado como credencial sensível
  - Explicação e configuração: [acesso remoto (kubeconfig)](../../../guides/tasks/kubernetes/configure-kubeconfig/)
  - Verificação: `stat --format '%a %n' ~/.kube/config`
  - Resultado esperado: `600`
  - Frequência: após qualquer cópia ou distribuição do arquivo

- [ ] Workloads segregados por namespace conforme responsabilidade/criticidade
  - Explicação e configuração: [prontidão de workloads](../application-readiness/#responsabilidade-e-criticidade)
  - Verificação: `kubectl get namespaces` e revisão manual da distribuição de workloads
  - Frequência: ao adicionar um novo workload

- [ ] NetworkPolicies aplicadas conforme os fluxos reais das aplicações
  - Explicação e configuração: [NetworkPolicy](../../../guides/tasks/networking/configure-network-policies/)
  - Verificação: `kubectl get networkpolicy --all-namespaces`
  - Frequência: ao alterar dependências de rede de um workload

- [ ] Pod Security Standards aplicados (ao menos `baseline`, idealmente `restricted`)
  - Explicação e configuração: [prontidão de workloads](../application-readiness/#serviceaccount-e-securitycontext)
  - Verificação: `kubectl get namespace <ns> -o jsonpath='{.metadata.labels}'`
  - Frequência: ao criar um namespace

- [ ] Secrets não versionados em texto claro e não expostos em logs
  - Explicação e configuração: [Infisical](../../../guides/tasks/secrets/install-infisical/)
  - Verificação: `grep -rIl "BEGIN.*PRIVATE KEY\|password" gitops/ 2>/dev/null || printf 'nenhuma ocorrência\n'`
  - Frequência: antes de cada commit no repositório GitOps

- [ ] Origem e versão das imagens controladas (sem tags flutuantes)
  - Explicação e configuração: [ciclo de vida de imagens](../../../learn/containers/image-lifecycle/)
  - Verificação: `kubectl get pods --all-namespaces -o jsonpath='{range .items[*].spec.containers[*]}{.image}{"\n"}{end}' | grep -E ':latest$|:lts$|:stable$'`
  - Resultado esperado: nenhuma linha retornada
  - Frequência: semanal

- [ ] Nenhum container privilegiado sem justificativa registrada
  - Explicação e configuração: [prontidão de workloads](../application-readiness/#serviceaccount-e-securitycontext)
  - Verificação: `kubectl get pods --all-namespaces -o json | python3 -c 'import json,sys; [print(p["metadata"]["namespace"], p["metadata"]["name"]) for p in json.load(sys.stdin)["items"] if any(c.get("securityContext",{}).get("privileged") for c in p["spec"]["containers"])]'`
  - Resultado esperado: nenhuma linha, ou apenas as justificadas
  - Frequência: semanal

- [ ] Capabilities reduzidas ao mínimo necessário
  - Explicação e configuração: [prontidão de workloads](../application-readiness/#serviceaccount-e-securitycontext)
  - Verificação: revisão manual de `securityContext.capabilities` nos manifests
  - Frequência: ao criar ou alterar um workload

- [ ] ServiceAccounts dedicadas, sem montagem de token quando não necessária
  - Explicação e configuração: [prontidão de workloads](../application-readiness/#serviceaccount-e-securitycontext)
  - Verificação: `kubectl get pods --all-namespaces -o jsonpath='{range .items[*]}{.spec.serviceAccountName}{" "}{.spec.automountServiceAccountToken}{"\n"}{end}'`
  - Frequência: ao criar um workload

- [ ] Acesso à API restrito ao necessário (sem exposição pública desnecessária)
  - Explicação e configuração: [acesso remoto (kubeconfig)](../../../guides/tasks/kubernetes/configure-kubeconfig/)
  - Verificação: `kubectl cluster-info` a partir de uma rede não autorizada deve falhar
  - Frequência: trimestral

- [ ] Certificados TLS válidos e renovação automática funcionando
  - Explicação e configuração: [instalar o cert-manager](../../../guides/tasks/certificates/install-cert-manager/)
  - Verificação: veja [revisão de certificados](../../maintenance/certificate-review/)
  - Frequência: semanal

- [ ] Varredura de postura do cluster sem falhas de severidade alta não justificadas
  - Explicação e configuração: [modelo mental do Kubescape](../../../learn/security/kubescape/) e [varrer um cluster com Kubescape](../../../guides/tasks/security/scan-cluster-with-kubescape/)
  - Verificação: `kubescape scan framework nsa --keep-local --severity-threshold High`
  - Resultado esperado: código de saída zero, ou falhas registradas como exceção documentada
  - Frequência: semanal, ou como gate de CI a cada mudança relevante

## Fontes e leitura adicional

- [Kubernetes — Security](https://kubernetes.io/docs/concepts/security/): visão geral oficial das áreas de segurança de um cluster Kubernetes.
- [Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/): define os perfis `privileged`, `baseline` e `restricted`.
