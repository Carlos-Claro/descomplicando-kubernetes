# Andamento do exercício Treinamento-ch2

Desafio:
`Você é o Engenheiro DevOps responsável por implantar uma nova aplicação de processamento de dados chamada "StressApp". Os desenvolvedores avisaram que essa aplicação pode ser um pouco... "gulosa" com memória RAM.

Seu objetivo é implantar essa aplicação no cluster Kubernetes, mas você precisa garantir que ela não derrube o nó ou afete outros vizinhos. Para isso, você usará seus conhecimentos sobre Pods, Resources (Requests/Limits) e Namespaces.`

[Primeiro arquivo](./pod-faminto.yaml):
```
    resources: 
      limits: 
        cpu: "0.5"
        memory: "200Mi"
      requests:
        cpu: "0.3"
        memory: "100Mi"
    command: ["stress"]
    args: ["--vm","1","--vm-bytes","250M","--vm-hang","1"]
```
Resposta:
- Comando: `kubectl get pods`
```
treinamento-ch2   0/1     CrashLoopBackOff   1 (14s ago)   18s
```
- Comando: `kubectl describe pods`
```
Last State:     Terminated
      Reason:       OOMKilled
Events:
  Type     Reason     Age                From               Message
  ----     ------     ----               ----               -------
  Normal   Scheduled  96s                default-scheduler  Successfully assigned default/treinamento-ch2 to kind-multinodes-worker
  Normal   Pulled     95s                kubelet            Successfully pulled image "polinux/stress" in 1.050335704s
  Normal   Pulled     92s                kubelet            Successfully pulled image "polinux/stress" in 1.033587938s
  Normal   Pulled     78s                kubelet            Successfully pulled image "polinux/stress" in 1.063501688s
  Normal   Created    53s (x4 over 95s)  kubelet            Created container stress
  Normal   Started    53s (x4 over 94s)  kubelet            Started container stress
  Normal   Pulled     53s                kubelet            Successfully pulled image "polinux/stress" in 1.04893687s
  Warning  BackOff    14s (x8 over 91s)  kubelet            Back-off restarting failed container
  Normal   Pulling    0s (x5 over 96s)   kubelet            Pulling image "polinux/stress"
```
Analise:
O teste está sendo realizado com 250MB em um servidor com 200MB disponível
Solução:
[Segundo arquivo](./pod-comportado.yaml):
```
resources:
      limits:
        cpu: "0.5"
        memory: "280Mi"
      requests:
        cpu: "0.3"
        memory: "250Mi"
    command: ["stress"]
    args: ["--vm","1","--vm-bytes","250M","--vm-hang","1"]

```
- Comando `kubectl get pods`
```
treinamento-ch2   1/1     Running   0          47m
```
- Comando `kubectl describe pods`
```
Status:           Running
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  50m   default-scheduler  Successfully assigned default/treinamento-ch2 to kind-multinodes-worker
  Normal  Pulling    50m   kubelet            Pulling image "polinux/stress"
  Normal  Pulled     50m   kubelet            Successfully pulled image "polinux/stress" in 1.064367034s
  Normal  Created    50m   kubelet            Created container stress
  Normal  Started    50m   kubelet            Started container stress

```




