---
title: Virtualização
description: Trilha de leitura desta seção, do modelo de máquina virtual aos containers de sistema, ao isolamento pré-Linux, ao espectro entre container e VM, e à compatibilidade de aplicação sem virtualização.
sidebar:
  order: 0
---

> **Para quem é:** quem já entende [como um container funciona por dentro](../containers/) e quer situar esse modelo entre as demais formas de isolamento: VMs, containers de sistema, e tudo que existe entre um container comum e uma VM completa.

Esta seção parte da comparação mais ampla (VM vs. container) e vai estreitando o foco: primeiro os containers de sistema, que rodam um sistema completo em vez de um processo só; depois duas formas de isolamento mais antigas que os namespaces do Linux, que já resolviam o mesmo problema à sua maneira; depois o espectro de tecnologias que ficam entre um container comum e uma VM completa; e por fim o QEMU/KVM em si, o isolamento de dispositivos via IOMMU que permite passar hardware real para uma VM, e o Wine, que resolve compatibilidade de aplicação Windows sem nenhuma das formas de isolamento anteriores. Nenhuma página desta trilha declara um vencedor universal: cada comparação lista critérios e contextos onde cada modelo é a resposta certa.

1. [Máquinas virtuais vs. containers](vms-vs-containers/) — a página âncora: hypervisor vs. kernel compartilhado, o que cada modelo isola de fato, custo por instância, superfície de ataque.
2. [Containers de sistema: LXC, Incus e systemd-nspawn](system-containers/) — o que muda quando um container roda um init completo e múltiplos serviços, em vez de um processo só.
3. [Solaris Zones e BSD Jails](zones-and-jails/) — isolamento antes dos namespaces do Linux, e o que o ecossistema Linux herdou dessas ideias.
4. [MicroVMs e sandboxes de processo](microvms-and-sandboxes/) — Firecracker, gVisor, `bubblewrap` e Kata Containers: o espectro entre container e VM.
5. [QEMU e KVM](qemu-and-kvm/) — emulação via TCG vs. virtualização acelerada por hardware, e a camada `libvirt`/`virt-manager`.
6. [IOMMU e passthrough de dispositivos](iommu-and-device-passthrough/) — o que protege a memória do host quando um dispositivo PCI real é passado para uma VM.
7. [Wine e Bottles](wine-and-bottles/) — tradução de API Win32, não virtualização: quando essa é a escolha certa em vez de uma VM completa.
