# Day 14 - AutoScaling no HPA

[Horizontal Pod Scaler](https://kubernetes.io/docs/concepts/workloads/autoscaling/horizontal-pod-autoscale). \
Através de leitura de metricas ele toma a decisão de aumentar ou diminuir os pods do k8s. \
Podemos utilizar metricas do prometheus ou metrics-server.\
Para isso precisa instalar o [metrics-server](https://kubernetes.io/docs/tasks/debug/debug-cluster/resource-metrics-pipeline/#metrics-server), [repositório](https://github.com/kubernetes-sigs/metrics-server): \
```
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
ou 
kubectl apply -f metrics-server-components.yaml
adicione no spec.tmplete.container.args - --kubelet-insecure-tls
```
utiliza `k get pods -n kube-system` para verificar o item `metrics-server-` esta running e ready. \
```
> k top nodes                                                                                     kubernetes-admin@kubernetes
NAME                 CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%   
dell-c-worker        120m         3%     1928Mi          24%       
pc-c-control-plane   704m         5%     9676Mi          63%       
prog-c-worker        316m         7%     3806Mi          49% 
```
