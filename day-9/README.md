# Day 9 - Ingress

[Referência](https://github.com/badtuxx/CertifiedContainersExpert/tree/main/DescomplicandoKubernetes/day-9)

## O que é?
Otimiza as funções do service loadBalancer ou nodePort. 
Expõe os services e tem controllers e rotas.

- Controllers
- Balanceamento de cargas
- Backend padrão


## configurações e ajustes no Kind

`kind create cluster --config kind-com-ingress.yaml`

## Install MetalLB

Para exibir IP, é necessário aplicativo que exponha o ip.

[MetaLB](https://metallb.io/usage)

preconfig:
```
$ kubectl edit configmap -n kube-system kube-proxy
--- edit set
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
mode: "ipvs"
ipvs:
  strictARP: true
```
`$ kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.15.3/config/manifests/metallb-native.yaml` ou `day-9/metallb-native.yaml`


## Ingress NGINX Controller
[Ingress nginx controller](https://github.com/kubernetes/ingress-nginx)

Modifica o tipo de service, nodeport para LoadBalancer e adiciona o anottation do ipaddress do control plane
```
name: ingress-nginx-controller
  namespace: ingress-nginx
  annotations:
    metallb.io/loadBalancerIPs: 192.168.0.106
type: LoadBalancer
```

[deploy de kind ](wget https://raw.githubusercontent.com/kubernetes/ingress-nginx/refs/heads/main/deploy/static/provider/kind/deploy.yaml)

[deploy de baremetal, para metal LB ](wget https://raw.githubusercontent.com/kubernetes/ingress-nginx/refs/heads/main/deploy/static/provider/baremetal/deploy.yaml)

Depois que o `kubectl get pods --namespace=ingress-nginx` estiver rodando:
```
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s
```
''