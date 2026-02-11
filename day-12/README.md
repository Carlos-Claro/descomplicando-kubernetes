# Service Monitors - day 12

Para criar um service monitor, precisaremos de nginx rodando em pods, com replicas. images do nginx e do nginx prometheus exporter [https://github.com/nginx/nginx-prometheus-exporter](https://github.com/nginx/nginx-prometheus-exporter).\
aplica `kubectl apply -f nginx-deployment.yaml`\
Para termos um volume, precisamos de um configmap, `kubectl apply -f nginx-configmaps.yaml`.\
precisamos de um service para apontar os metrics e conseguir integrar com o prometheus, `kubectl apply -f nginx-service.yaml`\
Criamos o service monitor com os parametros de endpoint:
```
endpoints:
  - port: metrics
    interval: 10s
    path: /metrics
    targetPort: 9113
```
`kubectl apply -f nginx-servicemonitor.yaml`

Após isso, podemos acessar o prometheus em: `kubectl port-forward -n monitoring svc/prometheus-k8s 39090:9090`\
em http://localhost:39090
- na aba: query, busque "nginx up" para ter um relatório se o nginx esta ok


---
## PodMonitor

utilizando um label diferente para conseguir verificar no prometheus um podmonitor, criamos e aplicamos os arquivos, nginx-pod.yaml e nginx-podmonitor.yaml

na aba target do prometheus, verificar o seletor select all pools

## Criando alerts

O que é um PrometheusRule?
O PrometheusRule é um recurso do Kubernetes que foi instalado no momento que realizamos a instalação dos CRDs do kube-prometheus. O PrometheusRule permite que você defina alertas para o Prometheus. Ele é muito parecido com o arquivo de alertas que criamos no nosso servidor Linux, porém nesse momento vamos fazer a mesma definição de alerta, mas usando o PrometheusRule.
aplica `k apply -f nginx-prometheusrule.yaml`
