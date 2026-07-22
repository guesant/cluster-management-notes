---
title: Materiais de estudo
description: Cursos, livros, laboratórios, knowledge bases e catálogos awesome-* usados como referência por este notebook, com critérios para avaliar recurso pago e a data da última verificação de cada um.
sidebar:
  order: 7
---

> **Para quem é:** quem já sabe o que estudar (via [mapa de certificações](../certifications/) e [progressão de estudo](../learning-paths/)) e procura materiais concretos para estudar com.

## Critérios para avaliar um recurso pago

Nenhum material desta página é recomendado cegamente; antes de pagar por um curso, livro ou laboratório, este notebook aplica os mesmos critérios a qualquer recurso:

- **Data da última atualização de conteúdo**, não a data de compra do usuário que deixou a avaliação; um curso de Kubernetes desatualizado há três anos ensina uma API que pode nem existir mais.
- **Quem é o autor ou instrutor**, e se essa pessoa opera a tecnologia de verdade (contribuição em projeto open source, histórico de produção) ou só reempacota documentação oficial em formato de vídeo.
- **Existe alternativa gratuita equivalente?** A documentação oficial e os exercícios interativos gratuitos (Killercoda, o próprio `kubernetes.io/docs/tutorials/`) cobrem uma fatia grande do que cursos pagos vendem; pagar faz mais sentido quando o valor real é a curadoria/ordem de estudo, não o conteúdo em si, que já é público.
- **Política de reembolso e acesso a atualizações futuras** do material, especialmente relevante para certificações com blueprint que muda periodicamente (como já visto nas páginas de [AWS](../certifications/aws/) e [Azure](../certifications/azure/)).

## As quatro obras de referência editorial deste notebook

Estas quatro obras foram auditadas quanto a licença em 2026-07-21 e inspiraram decisões estruturais deste próprio notebook (crédito completo em `material-referencias-editoriais.md`, documento interno de planejamento); aqui aparecem como recurso de estudo recomendado, respeitando a licença de cada uma.

| Obra | Autor | Licença | Última verificação |
| --- | --- | --- | --- |
| [k3s.guide](https://k3s.guide) | Aleksandar Grbic | Sem licença explícita publicada; todo direito reservado por padrão | 2026-07-21 |
| [Engenharia de Software Moderna](https://engsoftmoderna.info/) | Marco Tulio Valente (UFMG) | Uso pessoal; redistribuição e modificação proibidas | 2026-07-21 |
| [Fundamentos de Manutenção de Software](https://manutencaosoftware.org/) | Marco Tulio Valente | Uso pessoal; redistribuição e modificação proibidas | 2026-07-21 |
| [Learn Go with Tests](https://quii.gitbook.io/learn-go-with-tests) / [Aprenda Go com Testes](https://larien.gitbook.io/aprenda-go-com-testes) (tradução PT-BR) | Chris James (original), tradução mantida por larien | MIT | 2026-07-21 |

**k3s.guide** cobre uma trilha de homelab completa (hardware, rede física com MikroTik, K3s, Argo CD, Vault, Longhorn, backup, Ansible) com sobreposição temática grande com este notebook; sem licença publicada, então esta entrada é só link e crédito, nunca reuso de texto ou estrutura. **Engenharia de Software Moderna** e **Fundamentos de Manutenção de Software**, ambos de Marco Tulio Valente, cobrem fundamentos de engenharia de software (o primeiro, um livro-texto completo com exercícios; o segundo, focado em manutenção, depuração e dívida técnica) sob licença restritiva de uso pessoal: cite e linke, nunca copie trechos. **Learn Go with Tests**, sob MIT, é a única das quatro cuja licença permite reuso com atribuição; ainda assim, o valor citado por este notebook é o método (desenvolvimento orientado a teste que falha primeiro, já citado no EDITORIAL.md como inspiração de progressão didática), não o texto em si.

## Catálogos e listas `awesome-*`

Migrado de `toolbox/tools/overview.md` (o catálogo de ferramentas mantém só um link de redirecionamento para cá).

| Catálogo | Escopo | Observação |
| --- | --- | --- |
| [CNCF Cloud Native Landscape](https://landscape.cncf.io/) | Projetos e produtos cloud native organizados por categoria | Fonte mantida pela CNCF para descoberta; inclusão no mapa não equivale a recomendação ou maturidade CNCF |
| [Awesome Selfhosted](https://github.com/awesome-selfhosted/awesome-selfhosted) | Serviços e aplicações livres que podem ser hospedados pelo próprio usuário | Útil para descoberta; valide imagem, dependências, autenticação, backup e manutenção de cada projeto |
| [Awesome Docker](https://github.com/veggiemonk/awesome-docker) | Ferramentas, imagens, operação e recursos relacionados ao Docker | Lista comunitária; observe os marcadores de projetos comerciais ou sem atividade |
| [Awesome Compose](https://github.com/docker/awesome-compose) | Exemplos de Docker Compose mantidos pela organização Docker | Os próprios mantenedores classificam os exemplos como ponto de partida, não configuração pronta para produção |
| [Awesome Kubernetes](https://github.com/ramitsurana/awesome-kubernetes) | Projetos, materiais e ferramentas para Kubernetes | Catálogo amplo; confirme atividade e compatibilidade diretamente no projeto escolhido |
| [Awesome K8s Tools](https://github.com/vilaca/awesome-k8s-tools) | Índice automatizado de ferramentas para containers e Kubernetes | Ajuda a comparar categorias e atividade, mas métricas de repositório não substituem avaliação técnica |
| [Awesome Security](https://github.com/sbilly/awesome-security) | Segurança de rede, host, aplicações e DevSecOps, incluindo firewalls | Mistura ferramentas defensivas e ofensivas; defina autorização e ambiente isolado antes de testar qualquer item |
| [Awesome Sysadmin](https://github.com/awesome-foss/awesome-sysadmin) | Software livre para administração de sistemas e serviços | Útil para hosts, inventário e automação; verifique manutenção e privilégio exigido por cada ferramenta |
| [Awesome WAF](https://github.com/0xInfection/Awesome-WAF) | Pesquisa e ferramentas sobre Web Application Firewalls | WAF atua sobre tráfego de aplicação e não substitui UFW, firewalld, nftables ou o firewall dos nós K3s |
| [Awesome](https://github.com/sindresorhus/awesome) | Índice de listas comunitárias de muitos assuntos | Use como ponto de descoberta e siga até a documentação e o repositório oficial de cada projeto |

Antes de copiar um exemplo de um catálogo, confira a data da última release, mantenedores ativos, advisories de segurança, licença, imagens oficiais, checksums ou assinaturas, privilégios solicitados e procedimento de remoção. Faça a primeira implantação em ambiente isolado e registre por que a ferramenta foi escolhida (última verificação desta lista: 2026-07-22).

## Laboratórios e knowledge bases

| Recurso | O que cobre | Última verificação |
| --- | --- | --- |
| [Kubernetes.io: Tutorials](https://kubernetes.io/docs/tutorials/) | Tutoriais interativos oficiais, gratuitos, mantidos pelo próprio projeto Kubernetes | 2026-07-22 |
| [Killercoda](https://killercoda.com/) | Laboratórios interativos gratuitos, incluindo cenários específicos de preparação para CKA/CKAD/CKS | 2026-07-22 |
| [Kubernetes Failure Stories](https://k8s.af/) | Coleção de relatos reais de incidentes em produção com Kubernetes, agrupados por causa | 2026-07-22 |

## Páginas relacionadas

- [Mapa de certificações](../certifications/): as organizações e formatos de prova que estes materiais preparam.
- [Mapa de progressão de estudo](../learning-paths/): a ordem recomendada para consumir esses materiais.

## Referências

- [k3s.guide](https://k3s.guide): trilha de homelab completa, licença não publicada (até a escrita, 2026-07-21; confira o repositório para o estado atual de licenciamento).
- [Engenharia de Software Moderna](https://engsoftmoderna.info/): licença de uso pessoal (até a escrita, 2026-07-21).
- [Fundamentos de Manutenção de Software](https://manutencaosoftware.org/): licença de uso pessoal (até a escrita, 2026-07-21).
- [Learn Go with Tests](https://quii.gitbook.io/learn-go-with-tests) e [tradução PT-BR](https://larien.gitbook.io/aprenda-go-com-testes): MIT (até a escrita, 2026-07-21).
