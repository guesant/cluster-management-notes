sshd -t

EFFECTIVE_CONFIG_KEYS='^(authenticationmethods|allowgroups|disableforwarding'
EFFECTIVE_CONFIG_KEYS+='|kbdinteractiveauthentication|maxauthtries'
EFFECTIVE_CONFIG_KEYS+='|passwordauthentication|permitrootlogin'
EFFECTIVE_CONFIG_KEYS+='|pubkeyauthentication|usepam) '

printf '\nConfiguração efetiva:\n'
sshd -T | grep -E "${EFFECTIVE_CONFIG_KEYS}"

if [[ "${RELOAD_SSH,,}" == "s" ]]; then
  systemctl reload ssh
  systemctl --no-pager --full status ssh
else
  printf 'Configuração gravada, mas ainda não aplicada.\n'
fi
