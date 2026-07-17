# Portas publicadas pelo Docker

!!! warning
    Uma porta publicada pelo Docker pode não ser filtrada da maneira esperada pelo UFW ou pelo firewalld.

Com UFW, o Docker pode encaminhar o tráfego publicado antes que ele passe pelas chains normalmente gerenciadas pelo UFW. Com firewalld, o Docker cria uma zona chamada `docker`, cujo target padrão é `ACCEPT`.

Portanto, não considere uma porta publicada pelo Docker protegida apenas porque o firewall do host possui uma política padrão de bloqueio.

Para serviços que só devem ser acessados pelo próprio host, faça bind no loopback:

```yaml
ports:
  - "127.0.0.1:5432:5432"
```

Para serviços que devem ser acessados somente por uma rede específica, faça bind no endereço da interface correspondente:

```yaml
ports:
  - "192.168.1.10:5432:5432"
```

Evite publicar apenas como `5432:5432`, pois isso normalmente faz bind em todas as interfaces disponíveis.

