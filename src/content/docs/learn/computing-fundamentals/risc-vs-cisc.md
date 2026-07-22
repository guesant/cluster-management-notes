---
title: "RISC e CISC"
description: O que RISC e CISC descrevem de fato (o estilo do conjunto de instruções, não a complexidade interna do processador), as características históricas de x86 e ARM, por que a diferença é menos rígida em processadores atuais, e por que Linux, Windows e macOS não dependem rigidamente de nenhum dos dois.
sidebar:
  order: 4
---

> **Para quem é:** quem já ouviu os termos RISC e CISC associados a ARM e x86 e quer entender exatamente o que essa distinção descreve, e por que ela não impede um mesmo sistema operacional de rodar nas duas famílias de arquitetura.

RISC e CISC descrevem estilos de conjunto de instruções, ou ISA (instruction set architecture), a interface entre o software e o processador: quais instruções existem, quais registradores estão disponíveis, o formato de codificação de cada instrução, os tipos de dado suportados nativamente, o modelo de memória e os próprios níveis de privilégio descritos em [modos de privilégio e chamadas de sistema](../privilege-levels-and-system-calls/). A escolha entre os dois estilos não é uma medida de qualidade; é uma filosofia de design com trade-offs próprios, e a distinção importa menos hoje do que importou historicamente.

## CISC: Complex Instruction Set Computer

O exemplo mais relevante de arquitetura CISC em uso atual é x86 e sua extensão de 64 bits, x86-64. Historicamente, arquiteturas CISC se caracterizam por um número grande de instruções disponíveis, instruções de tamanhos variáveis (uma instrução x86 pode ocupar de 1 a 15 bytes), vários modos de endereçamento diferentes, e a existência de instruções únicas capazes de realizar operações relativamente complexas, incluindo acesso à memória combinado com a operação aritmética em uma única instrução. Um exemplo conceitual é `add rax, [memoria]`: essa instrução lê um valor da memória e já realiza a soma, sem exigir uma instrução separada de carga antes da soma.

## RISC: Reduced Instruction Set Computer

ARM, RISC-V, MIPS e SPARC são exemplos de arquiteturas RISC. Tradicionalmente, esse estilo se caracteriza por um conjunto de instruções mais regular, um modelo load/store (operações aritméticas trabalham apenas com registradores, nunca acessando a memória diretamente como parte da mesma instrução), menos modos de endereçamento e uma decodificação mais simples de cada instrução. No modelo load/store, a mesma soma do exemplo anterior exige três instruções separadas: carregar o valor da memória para um registrador, somar os registradores, e gravar o resultado de volta na memória, algo como `load x1, [memoria]`, `add x2, x1, x3`, `store x2, [memoria]`.

## A diferença moderna é menos rígida

Um processador x86 moderno recebe instruções CISC do programa, mas internamente as converte em micro-operações que se comportam de maneira muito próxima a instruções RISC: o decodificador quebra cada instrução complexa em unidades menores antes de entregá-las às unidades internas de execução. Ao mesmo tempo, arquiteturas ARM modernas incorporam instruções sofisticadas, extensões SIMD, execução fora de ordem e predição de desvios, recursos que a distinção RISC/CISC original não previa como exclusivos de um lado ou de outro. O resultado prático é que RISC e CISC continuam descrevendo bem a ISA, o contrato externo que o software vê, mas dizem cada vez menos sobre a complexidade real de implementação dentro do processador.

## Sistema operacional e arquitetura de CPU são dimensões independentes

Linux, Windows e macOS não estão presos a uma única família de ISA: os três rodam tanto em x86-64 quanto em ARM64, ainda que com pesos históricos diferentes. macOS rodou predominantemente em x86-64 (Intel) até a transição para Apple Silicon, quando ARM64 passou a ser a arquitetura principal; Android, apesar de também usar o kernel Linux, roda quase exclusivamente em ARM64. O mesmo conceito de chamada de sistema, descrito nas páginas anteriores desta seção, existe em qualquer uma dessas combinações, mas a instrução exata que dispara a transição para modo kernel muda conforme a arquitetura: `syscall` em x86-64, tanto Linux quanto Windows quanto macOS Intel; `svc` em ARM64, na mesma combinação de sistemas. O kernel de cada sistema operacional precisa ser compilado especificamente para a arquitetura de destino; não existe um binário de kernel único capaz de rodar indistintamente em x86-64 e ARM64.

## Páginas relacionadas

- [Como a CPU executa instruções](../how-cpus-execute-instructions/): o ciclo de execução e os componentes internos que processam qualquer ISA, RISC ou CISC.
- [Como Linux, Windows e macOS expõem seus serviços](../how-linux-windows-macos-expose-services/): a comparação entre a instrução de entrada no kernel usada por cada sistema operacional em cada arquitetura.

## Referências

- [Intel 64 and IA-32 Architectures Software Developer's Manuals](https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html): especificação completa da ISA x86-64.
- [Arm Architecture Reference Manual for A-profile architecture](https://developer.arm.com/documentation/ddi0487/latest/): especificação completa da ISA ARM64.
- [RISC-V Instruction Set Manual](https://riscv.org/technical/specifications/): especificação de uma ISA RISC aberta, usada como referência de design load/store.
