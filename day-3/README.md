# Deployments

Responsável por administrar as réplicas, montar e ajustar a disponibilidade e resiliência das réplicas.\
Para criar um modelo facilmente, utilize:
```
kubectl create deployment nginx --image nginx -o yaml > deployment.yaml
```
Adicionados limites:
```
- image: nginx
  name: nginx
  resources:
    limits:
      cpu: 0.5
      memory: 256Mi
    requests:
      cpu: 0.3
      memory: 64Mi
```
Problemas:\
- Nenhum deoployment ou pod foi criado
verifiquei com o comando `kubectl describe deployments.apps` \
Resposta:
```
Replicas:               3 desired | 0 updated | 0 total | 0 available | 0 unavailable
```
Solução: Restart kind\
Importante: sempre pare o kind e o kubectl quando for desligar o pc.\

---
Estratégia de roolout - vai destruir e criar a contagotas conforme a regra.\
`maxSurge: 1` quantidade que pode exceder a nossa quantidade de réplicas, pode ser utilizado porcentagem tambem.\
`maxUnavailable: 2` quantidade de modificações por vez
```
strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 2

```
estratégia Recreate - vai destruir tudo e criar de novo.
```
strategy:
    type: Recreate
```
no dois casos pode utilizar o comando `kubectl rollout status deployment -n ehclaro` para verificar o andamento.\
## Roolback
`kubectl rollout undo deployment -n ehclaro nginx-deployment`\
para verificar o que foi retornado ou ir para a mudança necessária:\
`kubectl rollout history deployment -n ehclaro nginx-deployment`
Retorno:\
```
deployment.apps/nginx-deployment 
REVISION  CHANGE-CAUSE
3         <none>
4         <none>
6         <none>
7         <none>
```
Para verificar o conteúdo desta revisão:
`kubectl rollout history deployment -n ehclaro nginx-deployment --revision 4 `
Resposta:
```
deployment.apps/nginx-deployment with revision #4
Pod Template:
  Labels:	app=nginx
	pod-template-hash=8866cd446
  Containers:
   nginx:
    Image:	nginx:1.16.0
    Port:	80/TCP
    Host Port:	0/TCP
    Limits:
      cpu:	200m
      memory:	128Mi
    Requests:
      cpu:	100m
      memory:	64Mi
    Environment:	<none>
    Mounts:	<none>
  Volumes:	<none>
  Node-Selectors:	<none>
  Tolerations:	<none>
```
Para retornar para uma específica:\
`kubectl rollout undo deployment -n ehclaro nginx-deployment --to-revision 6`
Podemos pausar os recursos enquanto realizamos o update
`kubectl rollout pause deployment -n ehclaro`
e restart com resume
`kubectl rollout resume deployment -n ehclaro`

