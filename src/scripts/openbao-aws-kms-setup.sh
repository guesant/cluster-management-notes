#!/bin/bash
set -euo pipefail

# Criar chave KMS no AWS
aws kms create-key \
  --description "OpenBao auto-unseal key" \
  --region "${AWS_REGION:-us-east-1}" \
  --output json

# Saída esperada:
# {
#   "KeyMetadata": {
#     "KeyId": "arn:aws:kms:us-east-1:123456789:key/abc-def-ghi",
#     ...
#   }
# }

# Guardar o ARN da chave (extrair da saída anterior)
# export KMS_KEY_ARN="arn:aws:kms:${AWS_REGION:-us-east-1}:123456789:key/abc-def-ghi"
