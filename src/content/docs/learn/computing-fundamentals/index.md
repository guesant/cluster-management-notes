---
title: Fundamentos de CPU, kernel e chamadas de sistema
description: Trilha de leitura desta seção, do ciclo de execução da CPU até o caminho completo de uma chamada de sistema, passando por modos de privilégio, RISC vs. CISC e a forma como Linux, Windows e macOS expõem seus serviços.
sidebar:
  order: 0
---

> **Para quem é:** quem opera hosts, containers e clusters no dia a dia e usa termos como "kernel", "syscall", "modo usuário" ou "descritor de arquivo" sem nunca ter parado para ver exatamente o que existe por baixo deles.

Esta seção segue uma ordem deliberada. Começa pelo nível mais baixo, o que a CPU de fato executa e como ela distingue instrução de dado, sobe para o mecanismo que impede um programa comum de acessar hardware diretamente e que serve de base para qualquer chamada de sistema, se abre em uma comparação de como Linux, Windows e macOS constroem sobre esse mecanismo suas próprias convenções, faz uma pausa para esclarecer o que RISC e CISC realmente descrevem, e fecha com o papel de interrupções e DMA na comunicação com dispositivos, amarrado por um exemplo de ponta a ponta. Ler fora de ordem é possível, já que cada página linka o que assume como conhecido, mas a sequência abaixo é a que menos exige ir e voltar.

1. [Como a CPU executa instruções: ciclo, arquitetura e componentes](how-cpus-execute-instructions/) — o ciclo fetch-decode-execute, a arquitetura de von Neumann e as arquiteturas Harvard modificadas atuais, a ULA e os demais componentes da CPU, e a diferença entre instrução, dado e entrada/saída.
2. [Modos de privilégio e chamadas de sistema](privilege-levels-and-system-calls/) — por que a CPU reserva certas operações para um modo privilegiado, a diferença entre API e ABI, e o caminho completo de uma chamada de sistema.
3. [Como Linux, Windows e macOS expõem seus serviços](how-linux-windows-macos-expose-services/) — syscalls e descritores de arquivo no Linux, a pilha Win32/ntdll/NT Native API no Windows, XNU/Mach/BSD no macOS, e uma comparação lado a lado.
4. [RISC e CISC](risc-vs-cisc/) — o que os dois termos realmente descrevem, por que a diferença é menos rígida em processadores atuais, e por que um sistema operacional não depende rigidamente de nenhum dos dois.
5. [Interrupções, DMA e o caminho completo de uma syscall](interrupts-dma-and-the-syscall-path/) — como o kernel conversa com dispositivos sem a CPU copiar dado por dado, a diferença entre chamada de função, syscall, interrupção e exceção, e um exemplo de ponta a ponta.

Esta seção é fundamento transversal para conteúdo já publicado em outras partes do notebook: [namespaces](../containers/namespaces/) e [cgroups](../containers/cgroups/) dependem de processos e chamadas de sistema descritos aqui, e [virtualização](../virtualization/) depende dos mesmos modos de privilégio usados para explicar rings e Exception Levels. [POSIX e padrões](../unix/posix-and-standards/) permanece a referência para a API comum entre Linux e macOS; esta seção cobre a camada abaixo dela, o que a CPU e o kernel fazem para tornar essa API possível.
