---
title: Firewalls
sidebar:
  order: 4.5
---

## Listar as regras ativas

```bash
ufw status verbose

firewall-cmd --list-all
# Para outra zona além da padrão
firewall-cmd --list-all --zone=public

nft list ruleset
```

**Quando usar:** ver rapidamente o que está liberado no host, como primeiro passo antes de investigar por que uma porta não responde.

**Considerações:**

- `ufw status verbose` mostra a política padrão e as regras numeradas; sem `verbose`, `ufw status` omite a política padrão, só lista as regras.
- `firewall-cmd --list-all` mostra a zona padrão do host; se a interface relevante estiver associada a outra zona, especifique `--zone`.
- `nft list ruleset` mostra o estado real das chains no kernel, a fonte de verdade final independentemente de qual ferramenta de alto nível gerou as regras. Útil quando o que o UFW ou o firewalld reportam não bate com o comportamento observado; veja [fundamentos de firewall no Linux](../../../learn/networking/firewalls/linux-firewall-fundamentals/).
- Rodar as três ferramentas no mesmo host raramente é o cenário real: use a que corresponde ao que está de fato ativo (`systemctl is-active ufw` ou `systemctl is-active firewalld`), nunca as duas ao mesmo tempo. Ver [UFW vs. firewalld](../../../learn/networking/firewalls/ufw-vs-firewalld/) para os critérios de escolha.

---

## Conferir se uma porta específica está liberada no firewall

```bash
ufw status | grep 443

firewall-cmd --query-port=443/tcp
firewall-cmd --query-service=https

nft list ruleset | grep 443
```

**Quando usar:** distinguir "a porta não está liberada no firewall do host" de "o serviço não está escutando" ou "o pacote não chega por outro motivo" (rede, NAT, camada externa).

**Considerações:**

- Isso confirma só a política estática configurada no host; não substitui um teste real de conectividade. Para testar se a porta responde de fato, veja [verificar se uma porta está aberta](../networking/#verificar-se-uma-porta-está-aberta).
- `firewall-cmd --query-port` retorna `yes` ou `no` e um código de saída correspondente (`0` para liberado), o que facilita usar o comando em script.
- Uma porta liberada no firewall do host ainda pode estar bloqueada por outra camada: firewall de borda, security group de provedor cloud, ou uma `NetworkPolicy` do Kubernetes quando o tráfego é entre Pods.

---

## Consultar o log de pacotes descartados

```bash
# UFW: habilitar log (se ainda não estiver) e consultar no log do kernel
ufw logging on
journalctl -k | grep '\[UFW BLOCK\]'

# firewalld: ver e habilitar o log de pacotes negados
firewall-cmd --get-log-denied
firewall-cmd --set-log-denied=all
journalctl -k -f | grep -Ei 'reject|drop'
```

**Quando usar:** confirmar se um pacote está sendo descartado pelo firewall do host, e não perdido em alguma outra camada, quando uma conexão falha sem nenhum erro do lado da aplicação.

**Considerações:**

- O UFW registra pacotes bloqueados no log do kernel, com o prefixo `[UFW BLOCK]`, mas só quando o logging está habilitado; o nível padrão (`low`) não registra todo pacote descartado, apenas os que não correspondem a nenhuma regra.
- O firewalld não loga pacotes negados automaticamente: `--get-log-denied` mostra o nível atual (`off` por padrão) e `--set-log-denied=all` habilita o log para todas as ações de negação, não só `REJECT`.
- O nftables não tem log implícito de descarte. Uma regra que derruba um pacote (`drop`) não gera entrada nenhuma no log a menos que a própria regra inclua explicitamente uma ação `log` antes do `drop`; isso surpreende quem espera um comportamento parecido com o do UFW por padrão.
- Em um host com tráfego alto, o volume de log pode mascarar o evento relevante; filtre por IP de origem ou porta específica com `grep` para isolar o pacote que interessa.

---

## Relacionado

- [Fundamentos de firewall no Linux](../../../learn/networking/firewalls/linux-firewall-fundamentals/): netfilter, nftables e as chains sobre as quais UFW e firewalld constroem suas regras.
- [UFW](../../../learn/networking/firewalls/ufw/) e [firewall com UFW (procedimento)](../../../guides/tasks/host/configure-ufw/).
- [firewalld](../../../learn/networking/firewalls/firewalld/) e [firewall com firewalld (procedimento)](../../../guides/tasks/host/configure-firewalld/).
- [Verificar se uma porta está aberta](../networking/#verificar-se-uma-porta-está-aberta), do lado da conectividade em vez da configuração do firewall.
