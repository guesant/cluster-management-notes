#!/bin/bash
set -euo pipefail

# Pré-requisito: KMS_KEY_ARN deve estar definido
: "${KMS_KEY_ARN:?KMS_KEY_ARN não definido}"

# Criar role IAM
aws iam create-role \
  --role-name "${IAM_ROLE_NAME:-openbao-unseal}" \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }'

# Criar inline policy para KMS
aws iam put-role-policy \
  --role-name "${IAM_ROLE_NAME:-openbao-unseal}" \
  --policy-name allow-kms-unseal \
  --policy-document "{
    \"Version\": \"2012-10-17\",
    \"Statement\": [
      {
        \"Effect\": \"Allow\",
        \"Action\": [
          \"kms:Decrypt\",
          \"kms:DescribeKey\",
          \"kms:GenerateDataKey\"
        ],
        \"Resource\": \"$KMS_KEY_ARN\"
      }
    ]
  }"

echo "IAM role '$IAM_ROLE_NAME' criada com sucesso"
