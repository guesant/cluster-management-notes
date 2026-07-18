GITOPS_SSH_KEY="${GITOPS_SSH_KEY:-${HOME}/.ssh/argocd_gitops}"

argocd repo add "${GITOPS_REPO_URL}" \
  --ssh-private-key-path "${GITOPS_SSH_KEY}"
