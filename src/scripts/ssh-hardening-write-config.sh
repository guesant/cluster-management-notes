cat >/etc/ssh/sshd_config.d/00-hardening.conf <<'SSHD_CONFIG'
PubkeyAuthentication yes
AuthenticationMethods publickey

PasswordAuthentication no
KbdInteractiveAuthentication no
PermitEmptyPasswords no

UsePAM yes

StrictModes yes

LoginGraceTime 30
MaxAuthTries 4

X11Forwarding no
PermitTunnel no
PermitUserEnvironment no

AllowGroups ssh-users
PermitRootLogin no

LogLevel VERBOSE
SSHD_CONFIG

if [[ "${DISABLE_FORWARDING,,}" == "s" ]]; then
  printf '\nDisableForwarding yes\n' >>/etc/ssh/sshd_config.d/00-hardening.conf
fi
