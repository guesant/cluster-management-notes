---
title: Ferramentas de diagnóstico de rede
description: Catálogo de ferramentas dedicadas de diagnóstico e captura de rede — nc, telnet, ss, lsof, mtr, iperf3, tcpdump e termshark — com o que avaliar antes de instalar cada uma.
sidebar:
  order: 1
---

> **Para quem é:** quem precisa sondar portas, inspecionar sockets e processos, diagnosticar perda de pacotes ao longo de uma rota, medir throughput real entre dois hosts, ou capturar e inspecionar o tráfego que passa por uma interface.

Este catálogo cobre a ferramenta em si (o que ela faz, quando se justifica instalá-la, riscos de uso). Para o comando pronto de uma tarefa pontual, veja o [cookbook de rede](../../commands/networking/): esta página não repete a sintaxe já documentada lá, só aponta para ela quando a ferramenta também aparece como recipe.

## mtr: rota com estatísticas contínuas por salto

`mtr` combina `ping` e `traceroute` em uma única ferramenta, atualizando continuamente a perda de pacotes e a latência de cada salto da rota até o destino, em vez de uma única passagem estática.

```bash
sudo apt install mtr-tiny
# ou mtr, no Debian/Ubuntu, dependendo do conjunto de dependências gráficas desejado
```

**Quando usar:** distinguir um problema de rede pontual (uma perda momentânea) de uma degradação persistente em um salto específico, o que uma única execução de `traceroute` não mostra. O comando em si, com as flags mais usadas, já está documentado em [testar a rota até um host](../../commands/networking/#testar-a-rota-até-um-host).

**Riscos:** `mtr` envia pacotes de sondagem contínuos enquanto roda; em redes com IDS/IPS sensível a varredura, isso pode disparar alertas de segurança se executado repetidamente contra um host que não é seu. Alguns roteadores intermediários limitam ou descartam esses pacotes por política, produzindo saltos marcados como perda sem que a rota esteja de fato com problema.

## nc e telnet: sondar uma porta manualmente

`nc` (netcat) abre uma conexão TCP ou UDP pontual para qualquer host e porta, útil tanto para testar se algo responde quanto para enviar ou receber dados brutos por um socket. `telnet`, originalmente um cliente de terminal remoto, é usado hoje quase exclusivamente para o mesmo teste pontual de porta TCP que `nc` faz, sem o restante das funções de `nc` (UDP, modo escuta, encadeamento com pipes).

```bash
sudo apt install netcat-openbsd
sudo apt install telnet
```

**Quando usar:** `nc` quando o teste precisa ir além de "a porta responde": abrir um socket em modo escuta para receber uma conexão de teste (`nc -l`), encaminhar a saída de um comando por um socket, ou testar UDP, que `telnet` não faz. `telnet` quando o objetivo é só confirmar que uma porta TCP aceita conexão, em um ambiente onde `nc` não está disponível; a sintaxe para esse teste específico já está em [verificar se uma porta está aberta](../../commands/networking/#verificar-se-uma-porta-está-aberta).

**Riscos:** `nc` é uma ferramenta de propósito genérico para mover dados por um socket; a mesma capacidade que a torna útil para diagnóstico (abrir um listener, encaminhar dados) também aparece em uso malicioso (shell reverso) quando disponível em um host comprometido. Isso não é motivo para evitar instalá-la em um host administrativo, mas justifica não deixá-la instalada por padrão em imagens de produção que não precisam dela. `telnet` transmite tudo, incluindo o próprio teste de porta, em texto claro; nunca o use para uma sessão de terminal remoto de verdade, apenas para o teste pontual de porta.

## ss: inspeção de sockets do kernel

`ss` lista sockets diretamente das estruturas internas do kernel, substituindo o antigo `netstat` (ainda presente em muitas distribuições, mas não mantido ativamente). Mostra conexões TCP/UDP, estado de cada uma e, com privilégio suficiente, qual processo é dono do socket.

```bash
sudo apt install iproute2
# geralmente já instalado por padrão, por ser parte do pacote base de rede
```

**Quando usar:** ver todas as conexões e portas em escuta de um host de uma vez, em vez de testar porta por porta com `nc`. As recipes prontas (listar conexões ativas, filtrar por porta, identificar o processo de uma porta) já estão em [listar conexões ativas](../../commands/networking/#listar-conexões-ativas) e em [identificar o processo que está usando uma porta](../../commands/networking/#identificar-o-processo-que-está-usando-uma-porta).

**Riscos:** nenhum risco específico; `ss` é somente leitura. A única limitação prática é que ver o processo dono de um socket de outro usuário exige root, o que é uma restrição do próprio kernel, não de `ss`.

## lsof: arquivos e sockets abertos por processo

`lsof` (list open files) lista todo descritor de arquivo aberto por processos no host, incluindo sockets de rede, já que no Linux um socket também é representado como um arquivo aberto. É mais genérico que `ss`: além de portas, mostra arquivos regulares, pipes e dispositivos abertos por um processo específico.

```bash
sudo apt install lsof
```

**Quando usar:** identificar qual processo detém uma porta específica (a mesma tarefa que `ss -ltnp | grep` resolve, com uma sintaxe mais direta para esse caso: `lsof -i :<porta>`), ou, além do escopo de rede, descobrir quais arquivos um processo mantém abertos, útil para diagnosticar por que um dispositivo ou partição não pode ser desmontado (`lsof <caminho>`, o mesmo comando usado em [particionar um disco](../../../guides/tasks/storage/prepare-host-disk/#troubleshooting) quando `parted` reporta o disco em uso).

**Riscos:** sem privilégio de root, `lsof` só mostra os processos do próprio usuário, o que pode dar a falsa impressão de que uma porta está livre quando na verdade está ocupada por um processo de outro usuário.

## iperf3: medição de throughput

`iperf3` mede a largura de banda real disponível entre dois hosts, executando um servidor em uma ponta e um cliente na outra que gera tráfego TCP ou UDP por um intervalo controlado.

```bash
sudo apt install iperf3

# No host que vai receber o teste (servidor)
iperf3 -s

# No host que inicia o teste (cliente)
iperf3 -c <ip-do-servidor>
# Teste UDP, útil para medir perda de pacotes em vez de só throughput TCP
iperf3 -c <ip-do-servidor> -u
```

**Quando usar:** confirmar se a largura de banda entre dois nós do cluster, ou entre um nó e um serviço externo, está de fato próxima do esperado para o link contratado ou para a interface de rede, antes de atribuir uma lentidão observada à aplicação em vez de à rede.

**Modelo de acesso:** o lado servidor (`iperf3 -s`) abre uma porta TCP/UDP (5201 por padrão) e aceita qualquer cliente que conseguir alcançá-la, sem autenticação. Rode o servidor só durante o teste, nunca como processo permanente exposto além de uma rede confiável, e pare-o (`Ctrl+C`) assim que a medição terminar.

**Riscos:** um teste de `iperf3` gera tráfego real e sustentado; rodá-lo em uma rede de produção durante horário de pico pode competir por banda com tráfego legítimo e mascarar ou piorar o próprio problema que está sendo investigado. Prefira uma janela de baixo uso, ou um segmento de rede isolado, quando o objetivo é medir a capacidade máxima do link.

## tcpdump e termshark: captura e inspeção de pacotes

`tcpdump` captura pacotes de uma interface de rede e os imprime ou grava em um arquivo `.pcap`; é a ferramenta de captura de referência em qualquer sistema Linux, sem dependência de interface gráfica. `termshark` é uma TUI (interface de terminal) que lê os mesmos arquivos `.pcap` e aplica os filtros de exibição do Wireshark, trazendo boa parte da capacidade de análise do Wireshark para um ambiente sem acesso gráfico, como um servidor remoto por SSH.

```bash
sudo apt install tcpdump

# Capturar na interface eth0, só pacotes na porta 443
sudo tcpdump -i eth0 port 443

# Gravar em arquivo para análise posterior
sudo tcpdump -i eth0 -w captura.pcap
```

```bash
# termshark não costuma estar nos repositórios padrão; confira o método de instalação
# atual na documentação oficial do projeto antes de instalar
termshark -r captura.pcap
```

**Quando usar:** confirmar se o tráfego esperado está de fato chegando a uma interface (ou saindo dela), inspecionar o conteúdo de um handshake TLS que está falhando, ou investigar um comportamento de rede que os testes de conectividade simples (`nc`, `curl`) não explicam sozinhos.

**Modelo de acesso e privilégios:** capturar pacotes exige privilégio para colocar a interface em modo de captura, por isso os comandos acima usam `sudo`; em produção, isso significa que quem captura tráfego consegue ver, no mínimo, os metadados de qualquer conexão que passe pela interface, mesmo sem decifrar payloads cifrados por TLS.

**Riscos:** uma captura sem filtro em uma interface com muito tráfego grava também dados de outras conexões e outros usuários da mesma rede, incluindo, em tráfego não cifrado, o conteúdo transmitido; restrinja a captura ao host, porta ou protocolo relevante com filtros (`port`, `host`, `net`) em vez de capturar tudo. Um arquivo `.pcap` gerado deve ser tratado como dado sensível: ele pode conter credenciais ou tokens de sessão trafegados em texto claro, e deve ser apagado depois de analisado, não deixado no host indefinidamente.

## Referências

- [mtr — página oficial do projeto](https://github.com/traviscross/mtr): repositório e documentação do `mtr`.
- [`nc(1)` — página de manual do netcat-openbsd](https://man.archlinux.org/man/nc.1.en): referência completa de opções, incluindo modo escuta e UDP.
- [`ss(8)` — página de manual](https://man7.org/linux/man-pages/man8/ss.8.html): referência de filtros e formatos de saída.
- [`lsof(8)` — página de manual](https://man7.org/linux/man-pages/man8/lsof.8.html): referência completa de opções e tipos de descritor listados.
- [iperf3 — documentação oficial](https://iperf.fr/iperf-doc.php): referência de opções, modos TCP/UDP e interpretação dos resultados.
- [tcpdump — documentação oficial](https://www.tcpdump.org/manpages/tcpdump.1.html): página de manual completa, incluindo a sintaxe de filtros (BPF).
- [termshark — repositório oficial](https://github.com/gcla/termshark): instalação, atalhos de teclado e diferenças em relação ao Wireshark completo.
