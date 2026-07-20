---
title: DNS
sidebar:
  order: 3
---

## Testar resolução de domínio

```bash
nslookup example.com
# ou
dig example.com
# ou
host example.com
```

**Quando usar:** verificar se um domínio resolve, ou descobrir o IP de um host.

**Considerações:**

- `nslookup` usa o resolvedor configurado em `/etc/resolv.conf`.
- `dig` mostra mais detalhes (TTL, tipo de registro, seção de autoridade).
- `host` é o mais direto dos três, útil para uma checagem rápida.

---

## Descobrir qual servidor DNS está configurado

```bash
cat /etc/resolv.conf
# ou, em sistemas com systemd-resolved
resolvectl status
```

**Quando usar:** confirmar qual resolvedor está em uso (Google Public DNS, Cloudflare, um resolvedor local, etc.).

**Considerações:**

- `/etc/resolv.conf` pode ser gerado e sobrescrito automaticamente pelo `systemd-resolved`; editá-lo manualmente em um sistema assim raramente é persistente.
- Em sistemas com `systemd-resolved`, `resolvectl status` mostra a configuração por interface, o que costuma ser mais preciso.

---

## Resolver contra um nameserver específico

```bash
dig @8.8.8.8 example.com
# Força a consulta a usar o DNS público do Google (8.8.8.8)
```

**Quando usar:** testar se um nameserver específico responde, ou contornar o cache do resolvedor local.

**Considerações:**

- `@<IP>` especifica qual resolvedor consultar, ignorando o configurado no sistema.
- Útil para diagnosticar diferenças de resposta entre resolvedores em uma configuração de DNS distribuído (split-horizon, por exemplo).

---

## Listar todos os registros de um domínio

```bash
dig example.com ANY
# Saída resumida
dig +short example.com

# Só registros A
dig +short example.com A

# Todos os tipos comuns, formatados
dig example.com +nocmd +noall +answer
```

**Quando usar:** auditoria de zona, ou descobrir todos os IPs e aliases associados a um domínio.

**Considerações:**

- Muitos nameservers bloqueiam ou limitam consultas `ANY` por política de segurança; não assuma que a ausência de resposta significa ausência de registros.
- `+short` produz a saída mais fácil de processar em scripts.
- `+nocmd +noall +answer` remove o cabeçalho e mostra só a seção de resposta.

---

## Verificar registros MX, TXT e CNAME

```bash
# Servidores de e-mail
dig example.com MX

# Registros de texto (SPF, DKIM, verificação de domínio)
dig example.com TXT

# Aliases
dig example.com CNAME
```

**Quando usar:** validar a infraestrutura de e-mail, verificar SPF/DKIM, ou resolver aliases.

**Considerações:**

- Em registros MX, um valor de preferência (`priority`) menor indica prioridade maior; é fácil interpretar isso ao contrário.
- Registros TXT também carregam SPF, DKIM e DMARC, além de tokens de verificação de propriedade de domínio usados por vários provedores.
- Um nome não pode ter um registro CNAME e outros registros (como A) simultaneamente, conforme a RFC do DNS.

---

## Testar resolução DNS interna do K3s

```bash
# A partir de um Pod temporário no cluster
kubectl run -it --rm debug --image=nicolaka/netshoot --restart=Never -- \
  nslookup kubernetes.default.svc.cluster.local

# Verificar o CoreDNS
kubectl get svc -n kube-system coredns
kubectl logs -n kube-system -l k8s-app=kube-dns
```

**Quando usar:** diagnosticar falha de resolução de Services internos, ou verificar a saúde do CoreDNS.

**Considerações:**

- O FQDN interno de um Service segue o padrão `<service>.<namespace>.svc.cluster.local`.
- O CoreDNS responde na porta 53, em UDP e TCP.
- Erros e cache misses recorrentes nos logs do CoreDNS costumam indicar sobrecarga ou uma `NetworkPolicy` bloqueando a porta 53.

---

## Medir a latência de uma resolução

```bash
time dig example.com
# mostra o tempo total gasto na consulta
```

**Quando usar:** diagnosticar lentidão de DNS, ou comparar resolvedores diferentes.

**Considerações:**

- A primeira consulta a um domínio costuma ser mais lenta, por não estar em cache em nenhum resolvedor intermediário.
- Consultas subsequentes ao mesmo nome tendem a usar cache e responder mais rápido.
- Uma latência acima de 100ms de forma consistente, mesmo com cache quente, costuma indicar um problema no caminho de resolução, não apenas uma consulta isolada lenta.
