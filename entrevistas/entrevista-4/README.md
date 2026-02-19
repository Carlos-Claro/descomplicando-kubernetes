# Entrevistas com Jeferson de IA -  Parte 4

1 -  imagina que você instalou o Kube-Prometheus-Stack no EKS, mas o Prometheus não tá encontrando as métricas da sua aplicação mesmo com o ServiceMonitor criado; o que você verificaria primeiro em relação às labels e ao seletor pra garantir que esse scraping funcione?
Primeiro observaria se os labels app.kubernetes.io, name e part-of estão corretos com kube-prometheus, se o namespace da regra está correto com monitoring e se a label prometheus aponta para k8s, após verificaria se a expr está correta e tem relação com os valores que são obtidos
2 - pensando em segurança e performance, como você justificaria o uso de imagens Distroless ou Wolfi no seu Dockerfile em vez de uma imagem Alpine ou Debian convencional, especialmente considerando a redução de vulnerabilidades?
Sempre devemos ter a preocupação com distro da aplicação que vamos utilizar, devemos buscar sempre distros com menos camadas, para que sejam mais rapidas e menos vulneráveis, que sejam enxutas e leves para que ocupem menos espaço e transferência de dados no momento da montagem, muito importante testar as aplicações com trivy ou docker scout, e buscar zero vulnerabilidades críticas, altas ou médias, o ideal é tudo zerado.
3 - como você configuraria uma PrometheusRule pra evitar o "fadiga de alertas", garantindo que um alerta de CPU alto só dispare se a métrica persistir por 5 minutos e tenha uma label de criticidade?
- alert: NginxHighCpuUsage
  expr: (sum(rate(container_cpu_usage_seconds_total{container!=""}[5m])) / sum(container_spec_cpu_quota{container!=""} / container_spec_cpu_period{container!=""})) > 0.8
  for: 1m
  labels:
  severity: critical
  annotations:
    summary: "Alto uso de CPU"
    description: "O uso de CPU é maior que 80% por mais de 5 minuto"