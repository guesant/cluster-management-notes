# Hardening do SSH

Hardening é a redução deliberada da superfície de ataque de um serviço. Nesta seção, o SSH continuará aceitando administração remota por chave pública, mas recusará senhas, login direto de `root`, usuários fora do grupo autorizado e funcionalidades que não forem necessárias. Essa configuração reduz as formas de entrada; ela não substitui o firewall nem a proteção da chave privada usada pelo administrador.

## Preparação

Escolha explicitamente a conta que continuará autorizada a entrar. Não use `$USER` em um shell de `root`, pois isso pode configurar a conta errada.

> **Executar em:** nó alvo que terá o SSH endurecido, como `root`.

```bash
bash <<'EOF'
set -euo pipefail

if (( EUID != 0 )); then
  printf 'Execute este bloco em um shell root aberto com sudo -i.\n' >&2
  exit 1
fi

read -r -p "Usuário que poderá acessar por SSH: " SSH_USER </dev/tty

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
EOF
```

Confirme, antes de alterar o servidor, que a conta entra usando uma chave e sem pedir a senha da conta:

> **Executar em:** estação administrativa com acesso SSH ao nó alvo.

```bash
read -r -p "Usuário SSH: " SSH_USER
read -r -p "Host ou IP do servidor: " SSH_HOST
ssh "${SSH_USER}@${SSH_HOST}"
```

Mantenha essa sessão aberta enquanto altera a configuração. Corrija também as permissões da chave autorizada com o bloco acima.

!!! info "Importante"
    A nova associação ao grupo só estará presente em novas sessões da conta.

## Configuração

O bloco abaixo grava a configuração completa, pergunta se todos os encaminhamentos devem ser bloqueados, valida o resultado e só então oferece o reload do serviço:

> **Executar em:** nó alvo que terá o SSH endurecido, como `root`.

```bash
bash <<'EOF'
set -euo pipefail

if (( EUID != 0 )); then
  printf 'Execute este bloco em um shell root aberto com sudo -i.\n' >&2
  exit 1
fi

install -d -o root -g root -m 0755 /etc/ssh/sshd_config.d

cat >/etc/ssh/sshd_config.d/00-hardening.conf <<'SSHD_CONFIG'
# Exigir autenticação por chave pública.
PubkeyAuthentication yes
AuthenticationMethods publickey

# Desabilitar autenticação por senha.
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitEmptyPasswords no

# Manter verificações de conta e sessão do PAM.
UsePAM yes

# Validar permissões do home, ~/.ssh e authorized_keys.
StrictModes yes

# Reduzir a janela e o número de tentativas de autenticação.
LoginGraceTime 30
MaxAuthTries 4

# Desabilitar funcionalidades não utilizadas.
X11Forwarding no
PermitTunnel no
PermitUserEnvironment no

# Restringir acesso e impedir login direto como root.
AllowGroups ssh-users
PermitRootLogin no

# Aumentar os detalhes úteis para auditoria.
LogLevel VERBOSE
SSHD_CONFIG

read -r -p \
  "Desabilitar todos os encaminhamentos SSH? [s/N]: " \
  DISABLE_FORWARDING \
  </dev/tty

if [[ "${DISABLE_FORWARDING,,}" == "s" ]]; then
  printf '\nDisableForwarding yes\n' \
    >>/etc/ssh/sshd_config.d/00-hardening.conf
fi

sshd -t

printf '\nConfiguração efetiva:\n'
sshd -T | grep -E \
  '^(authenticationmethods|allowgroups|disableforwarding|kbdinteractiveauthentication|maxauthtries|passwordauthentication|permitrootlogin|pubkeyauthentication|usepam) '

read -r -p "Recarregar o serviço SSH agora? [s/N]: " RELOAD_SSH </dev/tty

if [[ "${RELOAD_SSH,,}" == "s" ]]; then
  systemctl reload ssh
  systemctl --no-pager --full status ssh
else
  printf 'Configuração gravada, mas ainda não aplicada.\n'
fi
EOF
```

Não habilite `DisableForwarding` em servidores acessados por VS Code Remote SSH, túneis com `ssh -L`/`ssh -R`, bastion hosts ou conexões que usam `ProxyJump`.

## Validação

O bloco anterior já valida a sintaxe antes de permitir o reload. Abra outro terminal e teste uma nova conexão:

> **Executar em:** estação administrativa, em outro terminal.

```bash
read -r -p "Usuário SSH: " SSH_USER
read -r -p "Host ou IP do servidor: " SSH_HOST
ssh "${SSH_USER}@${SSH_HOST}"
```

Confirme também que senha e keyboard-interactive não são aceitos:

> **Executar em:** estação administrativa.

```bash
read -r -p "Usuário SSH: " SSH_USER
read -r -p "Host ou IP do servidor: " SSH_HOST

ssh \
  -o PubkeyAuthentication=no \
  -o PreferredAuthentications=password,keyboard-interactive \
  "${SSH_USER}@${SSH_HOST}"
```

A tentativa deve terminar com uma mensagem semelhante a:

```text
Permission denied (publickey).
```

Somente encerre a sessão SSH original depois que a nova conexão por chave funcionar.

## Fontes e leitura adicional

- [`sshd_config(5)` — OpenSSH/OpenBSD manual pages](https://man.openbsd.org/sshd_config): referência primária das diretivas de autenticação, acesso, encaminhamento, auditoria e validação usadas no hardening.
- [`sshd(8)` — OpenSSH/OpenBSD manual pages](https://man.openbsd.org/sshd): documenta o formato de `authorized_keys`, as permissões esperadas e o fluxo de autenticação do servidor.
- [OpenSSH server — Ubuntu Server documentation](https://ubuntu.com/server/docs/openssh-server/): orientações oficiais do Ubuntu para snippets em `sshd_config.d`, autenticação por chaves, validação com `sshd -t` e diagnóstico pelo journal.
