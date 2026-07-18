UFW_RULE=(allow in)

if [[ -n "${SSH_INTERFACE}" ]]; then
  UFW_RULE+=(on "${SSH_INTERFACE}")
fi

if [[ -n "${SSH_SOURCE_CIDR}" ]]; then
  UFW_RULE+=(from "${SSH_SOURCE_CIDR}")
fi

UFW_RULE+=(to any port "${SSH_PORT}" proto tcp)

printf 'Regra que será adicionada: ufw'
printf ' %q' "${UFW_RULE[@]}"
printf '\n'
ufw "${UFW_RULE[@]}"
