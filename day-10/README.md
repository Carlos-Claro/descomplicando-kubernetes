# Day 10 Ingress com TLS, annotations e cert-manager

## Preparação: 
- aplica day-5/weave-daemonset-k8s.yaml
preconfig metallb:
```
$ kubectl edit configmap -n kube-system kube-proxy
--- edit set
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
mode: "ipvs"
ipvs:
  strictARP: true
```
- aplica metallb day-9/metallb-native.yaml
- aplica ipaddess-pool.yaml
- aplica day-9/deploy-kind.yaml
ou
- aplica day-9/nginx-controller-deploy.yaml
```
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s
```

## cert-manager
ferramenta que possibilita gerenciar certificados

combinado com lets encript, auto gerenciavel

[docs](https://cert-manager.io/docs)

letsencrypt-prod - utilizar no modo produção quando já estiver tudo testado

letsencrypt-staging - sandbox, para criar o certificado varias vezes sem bloqueio

### instalando o cert-manager
Instalando com `kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.19.2/cert-manager.yaml`

verificando `kubectl get pods -n cert-manager`

utilizar os arquivos [./staging-issuer.yaml](staging-issuer.yaml) e [./production-issuer.yaml](production-issuer.yaml)

no ingress, adiciona os valores de annotations:
```
annotations:
    ...
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    ...
spec:
    tls:
  - hosts:
    - testes.carlosclaro.com.br
    secretName: testes-carlosclaro-tls
```
comandos importantes:
```
$ k get certificate
$ k describe certificate
$ k get secrets
$ k describe orders.acme.cert-manager.io
$ k get certificaterequests.cert-manager.io
$ k describe certificaterequests.cert-manager.io
$ k get challenges.acme.cert-manager.io
$ k describe challenges.acme.cert-manager.io
k describe clusterissuers.cert-manager.io
k describe issuers.cert-manager.io  
```


[Guia de anottations do ingress nginx](https://github.com/kubernetes/ingress-nginx/blob/main/docs/user-guide/nginx-configuration/annotations.md)

### inserindo anotations e auth:

altera arquivo ingress 

`htpasswd -c auth crclaro`

utilizar no secret

`k create secret generic nginx-senhas-secrets --from-file=auth`

adiciona no ingress:
```
nginx.ingress.kubernetes.io/auth-type: "basic"
nginx.ingress.kubernetes.io/auth-secret: "nginx-senhas-secrets"
nginx.ingress.kubernetes.io/auth-realm: "Autenticao necessaria"
cert-manager.io/cluster-issuer: "letsencrypt-prod"
```

### Configurando affinity cookie

```
nginx.ingress.kubernetes.io/affinity: "cookie"
nginx.ingress.kubernetes.io/session-cookie-name: "route"
nginx.ingress.kubernetes.io/session-cookie-hash: "sha1"
```

### Configurando upstream hashing
colabora com o apontamento de sistema, e para onde ele deve ser direcionado

```
nginx.ingress.kubernetes.io/upstream-hash-by: "$request_uri"
```

### Configurando canary deployment]
Balanceia a carga entre pods que vc deseja utilizar, exemplo em testes ou apontamento a/b

adiciona serviços com echo http com seguintes informações

```
nginx.ingress.kubernetes.io/canary: "true"
nginx.ingress.kubernetes.io/canary-weight: "10"
```

### Limitando requisições com ingress

```
nginx.ingress.kubernetes.io/limit-rps: "2"
```

teste de carga: [https://k6-io.translate.goog/?_x_tr_sl=en&_x_tr_tl=pt&_x_tr_hl=pt&_x_tr_pto=tc](https://k6-io.translate.goog/?_x_tr_sl=en&_x_tr_tl=pt&_x_tr_hl=pt&_x_tr_pto=tc)


*** Verificar como gerar log com o ip real do cliente, com metallb e ingress nginx controller