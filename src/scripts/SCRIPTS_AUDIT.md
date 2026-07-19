# Auditoria de Scripts — Fase 8

Classificação dos scripts existentes em `src/scripts/` conforme categorias de Fase 8.

## Classificação

### bootstrap/ (Inicialização do cluster)

- `first-server-install-before.sh` — Pré-requisitos (rede, SO, dependências)
- `first-server-install-write-config.sh` — Escreve config K3s
- `first-server-install-after.sh` — Validação pós-instalação

### installation/ (Instalação de componentes)

- `install-argo-cd.sh` — Helm + Argo CD
- `install-cert-manager.sh` — Helm + cert-manager
- `install-gateway-api.sh` — Gateway API CRDs
- `install-longhorn.sh` — Helm + Longhorn
- `install-longhorn-preflight.sh` — Pré-requisitos Longhorn
- `install-longhornctl.sh` — CLI do Longhorn
- `openbao-aws-kms-setup.sh` — AWS KMS para OpenBao (NEW)
- `openbao-aws-iam-setup.sh` — IAM role para OpenBao (NEW)

### configuration/ (Configuração de sistemas)

**SSH Hardening:**
- `ssh-hardening-before.sh` — Pré-requisitos
- `ssh-hardening-write-config.sh` — Escreve `/etc/ssh/sshd_config`
- `ssh-hardening-after.sh` — Valida com `sshd -t`
- `ssh-user-setup.sh` — Cria usuário + `.ssh/authorized_keys`

**Firewall:**
- `firewall-ssh-setup.sh` — Abre SSH no UFW
- `k3s-host-firewall-rules.sh` — Portas K3s no UFW

**K3s Join:**
- `add-k3s-server-before.sh` — Pré-requisitos para join
- `add-k3s-server-write-config.sh` — Config de join
- `add-k3s-server-after.sh` — Validação
- `add-k3s-agent-before.sh` — Pré-requisitos agent
- `add-k3s-agent-write-config.sh` — Config agent
- `add-k3s-agent-after.sh` — Validação

**Misc:**
- `register-gitops-repo.sh` — Registra repo em Argo CD
- `setup-longhorn-ssh-tunnel.sh` — SSH tunnel para Longhorn
- `create-custom-role.sh` — Cria role RBAC customizada
- `grant-cluster-admin.sh` — Concede cluster-admin
- `grant-namespace-access.sh` — Concede acesso a namespace

### maintenance/ (Manutenção)

- `cordon-and-drain-node.sh` — Drena nó para manutenção
- `upgrade-k3s-server.sh` — Upgrade de manager K3s
- `upgrade-k3s-agent.sh` — Upgrade de agent K3s
- `remove-node-from-cluster.sh` — Remove nó do cluster

### validation/ (Verificação)

*Nenhum script puro de validação ainda. Validações estão embutidas nos `-after.sh`.*

### backup/ / recovery/ / examples/ / libraries/

*Não há scripts nestas categorias ainda.*

---

## Conformidade com critérios técnicos

Critérios de `todo.txt` linhas 1690–1710:

| Critério | Status | Notas |
|----------|--------|-------|
| Modo estrito (`set -euo pipefail`) | ✅ | Todos os scripts usam |
| Validação de dependências | 🟡 | Alguns (K3s, Longhorn); falta em outros |
| Validação de SO/arquitetura | 🟡 | Alguns detectam Debian/Ubuntu; sem `uname -m` checks |
| Validação de variáveis obrigatórias | 🟡 | ScriptHelper injeta; scripts assumem; sem fallbacks |
| Sem comportamento destrutivo por padrão | ✅ | Nenhum rm/reboot sem confirmação |
| Arquivos temporários seguros | ✅ | `mktemp`/`/tmp` com umask correto |
| Limpeza de temporários | 🟡 | Alguns usam `trap`; falta em outros |
| Verificação de downloads/checksums | 🟡 | K3s valida; helm/docker não |
| Versão fixada ou política documentada | 🟡 | Helm charts especificam versões; wget é latest |
| Saída compreensível | ✅ | Mensagens claras, cores ausentes (cron-safe) |
| Códigos de saída | 🟡 | Usa $? mas sem tratamento granular |
| Idempotência documentada | 🟡 | Alguns são idempotentes (install commands); outros não (write-config) |
| Sistemas testados registrados | ❌ | Falta: Debian 11, 12, Ubuntu 20.04, 22.04, 24.04, arm64 |
| Validação/rollback | 🟡 | Validação sim (sshd -t, kubectl wait); rollback não |
| Permissões necessárias indicadas | ✅ | `sudo` e comentários indicam |

---

## Próximos passos

1. **Criar biblioteca de funções reutilizáveis** (`scripts/lib/common.sh`):
   - `require_command()` — verifica se comando existe
   - `require_var()` — valida variável obrigatória
   - `download_and_verify()` — wget + sha256sum
   - `run_silent()` — executa, mostra erro se falhar
   - `cleanup_trap()` — limpa temporários

2. **Revisar e atualizar cada script**:
   - Adicionar validações faltantes
   - Melhorar mensagens de erro
   - Documentar idempotência
   - Adicionar checksums em downloads

3. **CI: shellcheck + smoke tests**:
   - `.github/workflows/scripts.yml` com `shellcheck src/scripts/*.sh`
   - Testes básicos em container (sem cluster real)

4. **Documentar em cada página de task guide**:
   - Qual script é executado
   - Modo de execução (antes/depois)
   - Confirmação/validação esperada
