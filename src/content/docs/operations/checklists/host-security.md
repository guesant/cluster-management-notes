---
title: Segurança do host
sidebar:
  order: 2
---

> **Para quem é:** quem precisa confirmar ou auditar a postura de segurança de um host que executa K3s.

Checklist especializado referenciado pelo [checklist central](../cluster-operational-checklist/). Cada item aponta para a explicação, a configuração e um comando de verificação real: copie os itens aplicáveis para um runbook ou issue de auditoria.

- [ ] Atualizações de segurança do sistema operacional aplicadas automaticamente
  - Explicação e configuração: [atualizações automáticas de segurança](../../guides/tasks/host/configure-automatic-security-updates/)
  - Verificação: `systemctl is-active apt-daily-upgrade.timer && unattended-upgrade --dry-run --debug`
  - Frequência: contínua; revisar mensalmente

- [ ] Acesso SSH somente por chave, sem autenticação por senha
  - Explicação e configuração: [hardening de SSH](../../guides/tasks/host/harden-ssh/)
  - Verificação: `sshd -T | grep -E 'passwordauthentication|pubkeyauthentication'`
  - Resultado esperado: `passwordauthentication no` e `pubkeyauthentication yes`
  - Frequência: após qualquer alteração na configuração do SSH

- [ ] Login root via senha desabilitado
  - Explicação e configuração: [hardening de SSH](../../guides/tasks/host/harden-ssh/)
  - Verificação: `sshd -T | grep permitrootlogin`
  - Resultado esperado: `permitrootlogin prohibit-password` ou `no`
  - Frequência: após qualquer alteração na configuração do SSH

- [ ] Firewall do host ativo com política padrão de bloqueio
  - Explicação e configuração: [firewall com UFW](../../guides/tasks/host/configure-ufw/) ou [firewall com firewalld](../../guides/tasks/host/configure-firewalld/)
  - Verificação: `ufw status verbose` (ou `firewall-cmd --state && firewall-cmd --list-all`)
  - Resultado esperado: política padrão `deny (incoming)`
  - Frequência: após qualquer alteração de regras; revisar mensalmente

- [ ] Portas restritas por origem quando aplicável
  - Explicação e configuração: [firewall com UFW](../../guides/tasks/host/configure-ufw/#liberar-o-ssh-antes-de-aplicar-a-política)
  - Verificação: `ufw show added`
  - Frequência: após qualquer alteração de regras

- [ ] Proteção contra força bruta no SSH
  - Explicação e configuração: [Fail2Ban](../../guides/tasks/host/configure-fail2ban/)
  - Verificação: `fail2ban-client status sshd`
  - Frequência: contínua; revisar mensalmente

- [ ] Serviços desnecessários desabilitados
  - Explicação e configuração: [desabilitar serviços desnecessários](../../guides/tasks/host/disable-unnecessary-services/)
  - Verificação: `systemctl list-units --type=service --state=running`
  - Frequência: após provisionamento; revisar trimestralmente

- [ ] Permissões de arquivos sensíveis restritas
  - Explicação e configuração: [instalar o primeiro servidor K3s](../../guides/tasks/kubernetes/install-first-k3s-server/) (token e `config.yaml`)
  - Verificação: `stat --format '%a %n' /etc/rancher/k3s/config.yaml /var/lib/rancher/k3s/server/token`
  - Resultado esperado: `600` ou mais restritivo
  - Frequência: após qualquer reinstalação ou mudança manual

- [ ] Logs persistentes entre reinicializações
  - Explicação e configuração: [journal persistente](../../guides/tasks/host/configure-persistent-journal/)
  - Verificação: `journalctl --disk-usage`
  - Resultado esperado: volume reportado em `/var/log/journal`, maior que zero
  - Frequência: após provisionamento; revisar mensalmente

- [ ] Política de atualização do host documentada e seguida
  - Explicação e configuração: [runbook de manutenção](../../maintenance/maintenance-runbook/)
  - Verificação: revisão manual do registro de atualizações no runbook
  - Frequência: mensal

## Fontes e leitura adicional

- [Debian Security](https://www.debian.org/security/): referência oficial de segurança e avisos da distribuição usada como base neste notebook.
