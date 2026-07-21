---
title: Ferramentas interativas de diagnóstico
description: Catálogo de TUIs de diagnóstico — htop/btop, iotop, ncdu e strace — para investigação interativa além dos comandos pontuais do cookbook.
sidebar:
  order: 1
---

> **Para quem é:** quem já esgotou os comandos pontuais do [cookbook de troubleshooting](../../commands/troubleshooting/) e precisa de uma sessão interativa para navegar entre múltiplas fontes de diagnóstico (processos, I/O, espaço em disco, chamadas de sistema) no mesmo host.

Cada ferramenta aqui resolve um recorte específico de investigação; nenhuma substitui as outras. A escolha entre elas depende do sintoma: consumo de CPU/memória aponta para `htop`/`btop`, I/O elevado sem explicação aponta para `iotop`, espaço em disco consumido por algo não óbvio aponta para `ncdu`, e um processo travado ou falhando sem mensagem de erro clara aponta para `strace`.

## htop e btop: monitoramento interativo de processos

`htop` e `btop` são substitutos interativos do `top`, com navegação por teclado, cores e (no caso do `btop`) gráficos de série temporal para CPU, memória, rede e disco na própria interface. `top` já vem instalado na maioria dos sistemas Linux e cobre o caso básico, documentado em [monitorar CPU e memória em tempo real](../../commands/processes/#monitorar-cpu-e-memória-em-tempo-real); esta página trata do que `htop`/`btop` acrescentam a esse caso básico.

```bash
sudo apt install htop
sudo apt install btop
```

**Quando usar:** `htop` quando o objetivo é navegar, filtrar e ordenar processos interativamente (por CPU, memória, usuário), matar um processo direto da interface sem precisar descobrir o PID antes, ou visualizar a árvore de processos pai/filho. `btop` quando os gráficos de série temporal ajudam a correlacionar visualmente um pico de CPU com um pico de rede ou disco no mesmo instante, sem abrir três ferramentas separadas.

**Riscos:** nenhum risco específico além do já coberto pelo uso de `top`; ambos são somente leitura por padrão, exceto pela ação explícita de enviar sinal a um processo pela própria interface, que tem o mesmo efeito de `kill`/`pkill` executado manualmente.

## iotop: uso de disco por processo

`iotop` mostra o consumo de I/O de disco por processo, em tempo real, no mesmo formato de lista interativa do `top`. É a contrapartida, no nível de processo, do que `iostat` mostra no nível de dispositivo.

```bash
sudo apt install iotop

# Requer privilégios para ler estatísticas de I/O do kernel
sudo iotop
```

**Quando usar:** identificar qual processo específico está gerando a carga de I/O quando um disco está saturado, mas `df`/`du` (ver [verificar espaço em disco](../../commands/filesystems/#verificar-espaço-em-disco)) já mostraram que não é falta de espaço, e sim volume de leitura/escrita.

**Modelo de acesso:** `iotop` lê contadores de I/O por processo expostos pelo kernel via `/proc`; isso exige privilégio de root (ou a capability `CAP_NET_ADMIN`/acesso equivalente configurado), por isso o uso comum é sempre com `sudo`.

## ncdu: explorador interativo de uso de disco

`ncdu` (NCurses Disk Usage) constrói uma árvore navegável de uso de disco por diretório, permitindo descer em subdiretórios, ordenar por tamanho e apagar arquivos diretamente da interface, em vez de encadear `du -sh` manualmente em cada nível.

```bash
sudo apt install ncdu

ncdu /
# Ou um diretório específico, para uma varredura mais rápida
ncdu /var/log
```

**Quando usar:** quando [verificar espaço em disco](../../commands/filesystems/#verificar-espaço-em-disco) (`du -sh /* | sort -h`) já indicou qual diretório de topo está consumindo mais espaço, mas não qual subdiretório dentro dele, e navegar manualmente nível por nível seria mais lento que abrir a árvore interativa.

**Riscos:** a tecla de exclusão (`d` por padrão) apaga o arquivo ou diretório selecionado imediatamente após confirmação, sem passar pela lixeira do sistema; é fácil confundir a tecla de navegação com a de exclusão em uma sessão apressada. Rode uma varredura completa (`ncdu /`) como usuário sem privilégios elevados quando o objetivo for só inspecionar, reservando `sudo` para quando for necessário enxergar diretórios de outros usuários.

## strace: rastreamento de chamadas de sistema

`strace` intercepta e imprime cada chamada de sistema (syscall) que um processo faz ao kernel: abertura de arquivo, leitura, escrita, conexão de rede, alocação de memória, entre outras. É a ferramenta de diagnóstico mais próxima do kernel entre as desta página: enquanto `htop`/`iotop`/`ncdu` mostram sintomas agregados, `strace` mostra a interação exata que está falhando.

```bash
sudo apt install strace

# Anexar a um processo já em execução, pelo PID
sudo strace -p <PID>

# Rastrear um comando desde o início, com timestamp em cada linha
strace -t -o saida.log <comando>

# Só chamadas relacionadas a arquivos, mais fácil de ler em um processo ruidoso
strace -e trace=open,openat,read,write <comando>
```

**Quando usar:** um processo trava sem log de erro explicando o motivo, uma aplicação relata "permission denied" ou "file not found" para um caminho que aparenta estar correto, ou é preciso confirmar exatamente qual arquivo de configuração um binário está de fato lendo, entre várias localizações possíveis.

**Riscos:** interceptar cada chamada de sistema adiciona overhead sensível ao processo rastreado; rodar `strace` continuamente sobre um processo de produção sob carga real pode degradar sua performance a ponto de mascarar ou piorar o próprio problema investigado. Anexar-se a um processo de outro usuário com `-p` exige privilégio (`CAP_SYS_PTRACE` ou root), e alguns ambientes de container restringem essa capability por padrão, o que faz `strace` falhar dentro do container mesmo com `sudo` disponível no host.

## Referências

- [`htop` — página oficial](https://htop.dev/): documentação e capturas de tela da interface.
- [`btop` — repositório oficial](https://github.com/aristocratos/btop): recursos, temas e requisitos.
- [`iotop` — página do projeto](http://guichaz.free.fr/iotop/): descrição original da ferramenta e das colunas exibidas.
- [`ncdu` — documentação oficial](https://dev.yorhel.nl/ncdu): manual completo, incluindo atalhos de teclado.
- [`strace(1)` — página de manual](https://man7.org/linux/man-pages/man1/strace.1.html): referência completa de opções e filtros de chamada de sistema.
