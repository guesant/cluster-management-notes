if ! id "${SSH_USER}" >/dev/null 2>&1; then
  printf 'Usuário inexistente: %s\n' "${SSH_USER}" >&2
  exit 1
fi

SSH_HOME="$(getent passwd "${SSH_USER}" | cut -d: -f6)"
SSH_GROUP="$(id -gn "${SSH_USER}")"

if [[ -z "${SSH_HOME}" ]]; then
  printf 'Não foi possível identificar o home de %s.\n' "${SSH_USER}" >&2
  exit 1
fi

install -d \
  -o "${SSH_USER}" \
  -g "${SSH_GROUP}" \
  -m 0700 \
  "${SSH_HOME}/.ssh"

if [[ ! -s "${SSH_HOME}/.ssh/authorized_keys" ]]; then
  printf 'Chave ausente em %s/.ssh/authorized_keys.\n' "${SSH_HOME}" >&2
  exit 1
fi

chown "${SSH_USER}:${SSH_GROUP}" "${SSH_HOME}/.ssh/authorized_keys"
chmod 0600 "${SSH_HOME}/.ssh/authorized_keys"

groupadd --force ssh-users
usermod --append --groups ssh-users "${SSH_USER}"

printf '\nUsuário e grupo preparados:\n'
id "${SSH_USER}"
getent group ssh-users
