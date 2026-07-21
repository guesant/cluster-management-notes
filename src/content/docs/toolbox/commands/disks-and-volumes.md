---
title: Discos e volumes
sidebar:
  order: 8.5
---

## Listar os dispositivos de bloco do host

```bash
lsblk --output NAME,SIZE,TYPE,MOUNTPOINT,FSTYPE
```

**Quando usar:** ver todos os discos e partições reconhecidos pelo kernel, antes de particionar um disco novo ou de descobrir onde um volume está montado.

**Considerações:**

- A coluna `TYPE` distingue discos inteiros (`disk`) de partições (`part`) e volumes lógicos LVM (`lvm`); a hierarquia entre eles aparece na indentação do `NAME`.
- Um dispositivo listado sem `MOUNTPOINT` não está montado; isso não significa que está vazio, só que não está acessível pelo filesystem no momento.
- O nome do dispositivo (`/dev/sdb`, por exemplo) pode variar entre reinicializações em hosts com múltiplos discos removíveis ou controladoras adicionadas depois da instalação; para uma referência estável, veja identificar um dispositivo por UUID, abaixo.

---

## Identificar o filesystem e o UUID de um dispositivo

```bash
blkid /dev/sdb1
# /dev/sdb1: UUID="1a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d" TYPE="ext4" PARTUUID="..."

# Todos os dispositivos com filesystem reconhecido
blkid
```

**Quando usar:** confirmar se um dispositivo já tem um filesystem, qual o tipo, ou obter o UUID para referenciar o dispositivo de forma estável em `/etc/fstab` ou em automação.

**Considerações:**

- Um `blkid` sem saída para o dispositivo indica ausência de filesystem reconhecido, o estado esperado para um disco novo antes de particionar; ver [preparar um disco para o Longhorn](../../../guides/tasks/storage/prepare-host-disk/) para o procedimento completo de identificação e particionamento.
- `PARTUUID` identifica a partição em si (definido na tabela de partições); `UUID` identifica o filesystem criado dentro dela. Os dois mudam de valor se o filesystem for recriado, mesmo que a partição continue a mesma.
- Referenciar um disco por `UUID=` em vez de `/dev/sdX` em `/etc/fstab` evita que uma montagem aponte para o disco errado quando a ordem de detecção dos dispositivos muda entre boots.

---

## Verificar a saúde de um disco (SMART)

```bash
smartctl -a /dev/sda
# Relatório completo: atributos SMART, temperatura, horas ligado, setores realocados

# Resumo do status geral, sem o relatório completo
smartctl -H /dev/sda
# SMART overall-health self-assessment test result: PASSED

# Disparar um teste curto (não bloqueia o uso do disco durante a execução)
smartctl -t short /dev/sda
```

**Quando usar:** investigar suspeita de falha de disco (erros de I/O intermitentes, degradação de performance) antes que ela se torne perda de dados, ou como checagem periódica de discos em produção.

**Considerações:**

- `smartctl` faz parte do pacote `smartmontools`, que não vem instalado por padrão na maioria das distribuições.
- Discos NVMe usam uma página de atributos diferente da de discos SATA/SSD tradicionais; `smartctl -a` detecta o tipo automaticamente, mas alguns atributos (como `Media_Wearout_Indicator` em SSDs) só existem em determinados modelos e fabricantes.
- Um resultado `PASSED` em `-H` reflete a autoavaliação do firmware do disco, não uma garantia; atributos individuais como `Reallocated_Sector_Ct` crescendo ao longo do tempo são um sinal de degradação mesmo com o status geral ainda `PASSED`.
- `smartctl -t short` agenda um teste que roda em segundo plano no próprio controlador do disco; consulte o resultado depois com `smartctl -l selftest /dev/sda`, sem precisar esperar interativamente.
- Em um volume Longhorn ou de outro sistema de armazenamento distribuído, o disco físico com SMART degradado é o disco do nó, não o volume lógico exposto ao Pod; a réplica correspondente precisa ser tratada no nível do Longhorn, não só substituindo o disco.

---

## Relacionado

- [Preparar um disco para o Longhorn](../../../guides/tasks/storage/prepare-host-disk/): procedimento completo de identificação, confirmação e particionamento antes de adicionar um disco dedicado.
- [Verificar espaço em disco e inodes](../filesystems/#verificar-espaço-em-disco): uso do filesystem já montado, complementar à visão de dispositivos de bloco desta página.
