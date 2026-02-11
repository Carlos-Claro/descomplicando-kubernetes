# Day 11 - Prometheus operator / Kube-Prometeus

[https://github.com/prometheus-operator/kube-prometheus](https://github.com/prometheus-operator/kube-prometheus)

É uma ferramenta que colabora com o monitoramento, configurações iniciais para coleção de estatisticas, emissão de alertas, com dashboard e outras funcionalidades.

clone do projeto na pasta ../prometheus

`git clone https://github.com/prometheus-operator/kube-prometheus.git`

após aplicar o kube-prometheus/manifests
´kubectl create -f manifests/setup´

instalar itens do manifest: `k apply -f manifests`

Acessando dashboard: `kubectl port-forward -n monitoring svc/grafana 3000:3000 `

acesso localhost:3000

ou aplica `kubectl apply -f network-policy.yaml` e `kubectl apply -f grafana-ingress.yaml`

acesso: grafana.carlosclaro.com.br

expoem prometheus: `kubectl port-forward -n monitoring svc/prometheus-k8s 39090:9090`

expoem alertmanager: `kubectl port-forward -n monitoring svc/alertmanager-main 39093:9093`

## Service Monitor

principais recusrsos do promeheus operator, svc monitor monitora serviço X e faz um target para ele saber que precisa pegar as métricas do serviço

`k get servicemonitors.monitoring.coreos.com -n monitoring `

