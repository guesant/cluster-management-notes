---
title: Infraestrutura como Código (IaC) — Terraform, OpenTofu, Pulumi
sidebar:
  order: 1
---

> **Para quem é:** operadores que querem provisionar máquinas e infraestrutura (não só apps dentro de clusters) via código.

IaC permite descrever infraestrutura (VMs, redes, firewalls, storage) como código versionado e reproducível.

## O problema

**Sem IaC:**

- Clica na AWS console
- Cria VM, configura rede, abre firewall
- Semana depois: esquece como fez
- Precisa recriar? Clica tudo novamente

**Com IaC:**

```hcl
resource "aws_instance" "k3s_server" {
  ami = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.medium"
  # ...
}
```

- Declarativo, versionado no git, reproducível

## Terraform — Abordagem declarativa (mais adotada)

**O que é:**

- Language declarative (HCL)
- State file (rastreia o que foi criado)
- Providers (AWS, GCP, Azure, Kubernetes, Helm, etc.)

**Funcionalidade:**

- Plan (mostra o que vai mudar)
- Apply (cria/atualiza)
- Destroy (deleta)
- Modules (reutilização)

**Quando usar:**

- Multi-cloud (Terraform funciona em todos)
- Já tem expertise Terraform
- Quer enterprise support (Hashicorp)

**Trade-off:**

- State file é ponto crítico (perder = disaster)
- Syntax HCL é específica (não é linguagem general-purpose)

---

## OpenTofu — Fork open-source

**O que é:**

- Fork de Terraform após mudança de licença
- Compatível com Terraform (drop-in replacement)

**Funcionalidade:**

- Idêntica a Terraform (mesmo HCL)
- Community-driven (sem Hashicorp lock-in)

**Quando usar:**

- Quer evitar Hashicorp (licença/vendor lock)
- Terraform expertise transfere direto

---

## Pulumi — Programmatic IaC

**O que é:**

- IaC em linguagens reais (Python, Go, TypeScript, etc.)
- Sem arquivo de linguagem custom

**Funcionalidade:**

- Code como verdadeira lógica (loops, conditionals, functions)
- Mesmos providers que Terraform
- State backend (similar a Terraform)

**Quando usar:**

- Prefere Python/Go/TypeScript a HCL
- IaC com lógica complexa (loops aninhados, etc.)
- Já tem software engineers (não só ops)

**Trade-off:**

- Menos maduro que Terraform para production
- Comunidade menor

---

## Comparação

| Aspecto | Terraform | OpenTofu | Pulumi |
| --------- | --- | --- | --- |
| **Linguagem** | HCL | HCL | Python/Go/TS |
| **Multi-cloud** | ✅ Sim | ✅ Sim | ✅ Sim |
| **Curva** | Média (HCL novo) | Média | Suave (linguagem conhecida) |
| **Lógica complexa** | Difícil (HCL limitada) | Difícil | Fácil (verdadera linguagem) |
| **Enterprise** | Hashicorp | Community | Pulumi Inc. |
| **Community** | Maior | Crescente | Menor |

---

## Critérios de decisão

**Terraform** é a escolha mais adotada quando:

1. Comunidade grande importa (mais exemplos, Stack Overflow)
2. Módulos reutilizáveis (Terraform Registry)
3. Multi-cloud necessário
4. Equipe já usa HCL

**OpenTofu** se a licença de Terraform for bloqueador (mesmo padrão, comunidade).

**Pulumi** se a equipe prefere code-first (Python/Go/TypeScript com verdadeira lógica).

---

## State management (crítico)

Terraform/Pulumi precisam de state file:

- **Local:** `terraform.tfstate` (risco: perde tudo se disco morre)
- **S3:** estado no S3 com lock (dynodb)
- **Remote:** Terraform Cloud/Pulumi Service (gerenciado)

**Recomendação:** Remote (S3 ou Terraform Cloud), nunca local em production.

---

## Modularização

```hcl
# root module
module "k3s_cluster" {
  source = "./modules/k3s"
  
  instance_type = "t3.medium"
  count = 3
}
```

Reutilizar módulos em múltiplos clusters.

---

## Decisão prática

**Comece com Terraform** se:

- Multi-cloud
- Quer comunidade grande
- Infraestrutura simples–moderada

**Mude para Pulumi** se:

- Infraestrutura com lógica complexa
- Equipe com eng. software expertise

**Use OpenTofu** se:

- Vendor lock-in com Hashicorp for problema

---

## Referências

- [Terraform documentation](https://www.terraform.io/docs/): guia oficial.
- [OpenTofu documentation](https://opentofu.org/docs/): fork open-source.
- [Pulumi documentation](https://www.pulumi.com/docs/): programmatic IaC.
