export SOPS_AGE_KEY_FILE=age-key.txt
sops --encrypt --in-place "${SECRET_FILE_PATH}"
