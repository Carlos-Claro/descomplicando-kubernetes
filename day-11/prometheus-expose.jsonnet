'local kp =
  (import 'kube-prometheus/main.libsonnet') +
  {
    values+:: {
      common+: {
        namespace: 'monitoring',
      },
    },
    prometheus+:: {
      prometheus+: {
        spec+: {
          externalUrl: 'http://grafana.carlosclaro.com.br',
        },
      },
    },
    ingress+:: {
      'prometheus-k8s': {
        apiVersion: 'networking.k8s.io/v1',
        kind: 'Ingress',
        metadata: {
          name: $.prometheus.prometheus.metadata.name,
          namespace: $.prometheus.prometheus.metadata.namespace,
        },
        spec: {
          rules: [{
            host: 'grafana.carlosclaro.com.br',
            http: {
              paths: [{
                backend: {
                  service: {
                    name: $.prometheus.service.metadata.name,
                    port: 'web',
                  },
                },
              }],
            },
          }],
        },
    },
  };

// Output a kubernetes List object with both ingresses (k8s-libsonnet)
k.core.v1.list.new([
  kp.ingress['prometheus-k8s'],
])