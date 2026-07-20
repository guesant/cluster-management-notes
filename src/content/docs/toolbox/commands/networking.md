---
title: Rede
sidebar:
  order: 4
---

## Testar conectividade com um host

```bash
ping -c 3 example.com
# ou sem limite de pacotes
ping example.com

# Encerrar após 5 segundos, independente do número de respostas
ping -w 5 example.com
```

**Quando usar:** verificar se um host está acessível, ou medir latência aproximada.

**Considerações:**

- ICMP (o protocolo usado pelo `ping`) pode estar bloqueado por firewall mesmo com o host acessível por outros protocolos; a ausência de resposta não prova que o serviço está fora do ar.
- `-c N`: envia exatamente N pacotes e encerra (no `ping` do Linux/iputils).
- `-w N`: define um prazo total de N segundos para o comando, não um timeout por pacote; não confundir com `-W`, que define o tempo de espera por cada resposta individual.

---

## Verificar se uma porta está aberta

```bash
# Com netcat
nc -zv example.com 443
# -z fecha a conexão logo após conectar, -v mostra detalhes

# Com telnet
telnet example.com 443

# Com /dev/tcp, sem depender de nenhum utilitário externo
timeout 1 bash -c 'cat </dev/null >$(echo /dev/tcp/example.com/443)' && echo "Aberta" || echo "Fechada"
```

**Quando usar:** confirmar se uma porta está aberta e aceitando conexões.

**Considerações:**

- `netcat` é a opção mais portável entre distribuições.
- `telnet` costuma exigir instalação explícita nas distribuições atuais, que não o incluem mais por padrão.
- `/dev/tcp` é um recurso específico do Bash; funciona sem instalar nada, mas não existe em `sh` puro (dash, por exemplo).

---

## Listar conexões ativas

```bash
# Forma clássica
netstat -tlnp

# Equivalente moderno, geralmente mais rápido
ss -tlnp

# Filtrar por porta
ss -tlnp | grep :8080

# Filtrar por estado da conexão
ss -tnp state established
```

**Quando usar:** diagnosticar uma porta já em uso, identificar qual processo a ocupa, ou monitorar conexões ativas.

**Considerações:**

- `-t` seleciona conexões TCP; `-u` seleciona UDP.
- `-l` mostra sockets em modo de escuta (listening); `-n` evita a resolução de hostnames, o que acelera a saída.
- `-p` inclui o processo dono de cada socket (normalmente exige privilégios de root para conexões de outros usuários).
- `ss` lê diretamente das estruturas do kernel e tende a ser mais rápido que `netstat` em sistemas com muitas conexões.

---

## Identificar o processo que está usando uma porta

```bash
# Qual processo está na porta 3000?
lsof -i :3000

# Equivalente com ss
ss -ltnp | grep :3000

# Com privilégios elevados, para ver processos de outros usuários
sudo lsof -i :3000
```

**Quando usar:** descobrir qual aplicação está ocupando uma porta, ou diagnosticar um conflito de porta já em uso.

**Considerações:**

- Sem privilégios de root, `lsof` só mostra processos do próprio usuário.
- `-i` filtra por sockets de rede (internet sockets).
- Identificar o processo correto antes de encerrá-lo evita derrubar um serviço não relacionado por engano.

---

## Testar a rota até um host

```bash
traceroute example.com
# ou, com estatísticas contínuas por salto
mtr example.com

# Uma única passagem, sem o modo interativo
mtr -c 1 example.com
```

**Quando usar:** diagnosticar latência de rede, ou identificar por quais saltos (hops) uma conexão passa.

**Considerações:**

- `traceroute` mostra uma única passagem pela rota no momento da execução.
- `mtr` combina `ping` e `traceroute`, atualizando estatísticas de perda e latência por salto continuamente.
- Roteadores intermediários podem bloquear ou limitar as respostas usadas por essas ferramentas, produzindo saltos marcados como `*` mesmo quando a rota funciona.

---

## Listar as rotas do host

```bash
# Comando atual, recomendado
ip route show

# Comando legado, ainda disponível em muitas distribuições
route -n

# Só a rota padrão
ip route | grep default
```

**Quando usar:** verificar o gateway padrão, ou diagnosticar um problema de roteamento.

**Considerações:**

- `ip route` faz parte do pacote `iproute2` e é a ferramenta recomendada atualmente; `route` pertence ao pacote `net-tools`, mais antigo e nem sempre instalado por padrão.
- Sem `-n`, o `route` tenta resolver os IPs em hostnames, o que deixa a saída mais lenta.

---

## Adicionar ou remover uma rota

```bash
# Adicionar rota
sudo ip route add 192.168.2.0/24 via 192.168.1.1

# Remover rota
sudo ip route del 192.168.2.0/24 via 192.168.1.1

# Confirmar
ip route show | grep 192.168.2
```

**Quando usar:** roteamento customizado, laboratórios de rede, ou túneis manuais.

**Considerações:**

- Requer privilégios de root.
- Uma rota adicionada com `ip route add` é temporária e se perde ao reiniciar o host.
- Para tornar a rota persistente, configure-a na ferramenta de rede do sistema (`/etc/netplan/`, `NetworkManager`, ou equivalente), em vez de repetir o comando manual a cada boot.
