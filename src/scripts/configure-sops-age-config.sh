cat >.sops.yaml <<EOF
creation_rules:
  - path_regex: gitops/apps/security/secrets/.*\.yaml$
    age: ${AGE_PUBLIC_KEY}
EOF
