ssh -N \
  -L "${LOCAL_PORT}:127.0.0.1:${MANAGER_PORT}" \
  "${SSH_USER}@${SSH_HOST}"
