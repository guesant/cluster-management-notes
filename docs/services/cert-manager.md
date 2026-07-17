# cert-manager

Os comandos desta página devem ser executados em um servidor ou em uma estação administrativa que tenha `kubectl`, Helm, acesso à API e um kubeconfig válido.

## Como o cert-manager trabalha

O cert-manager é um controller que automatiza solicitação, emissão e renovação de certificados. Um `Issuer` representa uma autoridade ou um método de emissão limitado a um namespace; um `ClusterIssuer` oferece essa capacidade ao cluster inteiro. Um recurso `Certificate` declara nomes DNS, validade desejada, Secret de destino e qual Issuer deve ser usado. Quando a emissão termina, o cert-manager grava o certificado e a chave privada em um Secret e tenta renová-los antes do vencimento.

Com ACME e desafio DNS-01, o cert-manager comprova o controle de um domínio criando temporariamente um registro DNS TXT pelo provedor configurado. Esse método também pode emitir certificados wildcard e não exige que o serviço solicitado já esteja publicamente acessível. A credencial do provedor DNS pode alterar registros e deve permanecer em um Secret ou em um gerenciador de segredos, nunca no repositório Git.

Instalar o cert-manager não emite certificados por si só. Depois da instalação ainda é necessário criar um `Issuer` ou `ClusterIssuer` e recursos `Certificate`, como nos templates GitOps deste repositório. O Secret TLS resultante pode ser referenciado por um listener HTTPS do Gateway, conforme o [guia de Gateway API e Traefik](../networking/gateway-api-and-traefik.md). Referências: [configuração de Issuers](https://cert-manager.io/docs/configuration/) e [recurso Certificate](https://cert-manager.io/docs/usage/certificate/).

Os CRDs da Gateway API devem existir antes da instalação. Se forem instalados depois, reinicie o deployment do cert-manager para que a integração seja detectada.

> **Executar em:** qualquer máquina com `KUBECONFIG` e acesso administrativo à API.

```bash
read -r -p "Versão do cert-manager [v1.20.0]: " CERT_MANAGER_VERSION
read -r -p \
  "Resolvers para DNS-01 [1.1.1.1:53,8.8.8.8:53]: " \
  DNS01_RECURSIVE_NAMESERVERS

CERT_MANAGER_VERSION="${CERT_MANAGER_VERSION:-v1.20.0}"
DNS01_RECURSIVE_NAMESERVERS="${DNS01_RECURSIVE_NAMESERVERS:-1.1.1.1:53,8.8.8.8:53}"

helm upgrade --install cert-manager \
  oci://quay.io/jetstack/charts/cert-manager \
  --version "${CERT_MANAGER_VERSION}" \
  --namespace cert-manager \
  --create-namespace \
  --set crds.enabled=true \
  --set config.gatewayAPI.enabled=true \
  --set-json "extraArgs=[\
    \"--dns01-recursive-nameservers-only\",\
    \"--dns01-recursive-nameservers=${DNS01_RECURSIVE_NAMESERVERS}\"\
  ]" \
  --wait \
  --timeout 10m
```

Valide a instalação:

> **Executar em:** qualquer máquina com `KUBECONFIG` e acesso à API.

```bash
kubectl --namespace cert-manager rollout status deployment/cert-manager --timeout=180s
kubectl --namespace cert-manager get pods
kubectl get crd certificates.cert-manager.io clusterissuers.cert-manager.io
helm --namespace cert-manager status cert-manager
```

Se os CRDs da Gateway API tiverem sido instalados depois do cert-manager:

> **Executar em:** qualquer máquina com `KUBECONFIG` e acesso administrativo à API.

```bash
kubectl --namespace cert-manager rollout restart deployment/cert-manager
kubectl --namespace cert-manager rollout status deployment/cert-manager --timeout=180s
```

Referência: [cert-manager com Gateway API](https://cert-manager.io/docs/usage/gateway/).
