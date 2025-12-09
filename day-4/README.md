# Day-4
Criar um deployment com serviços que utilizo no dia-a-dia
- service 1: 
    - httpd:2.4.66
    - ports: 80 / 443 
    - [Documentação](https://hub.docker.com/_/httpd)
- service 2: 
    - ubuntu/bind9:edge
    - [Documentação](https://hub.docker.com/r/ubuntu/bind9)
- service 3: 
    - mongo:7-jammy
    - ports: 27017
    - [Documentação](https://hub.docker.com/_/mongo)
- service 4: 
    - mysql:8.0.44-debian
    - ports: 3306
    - [Documentação](https://hub.docker.com/_/mysql)
- service 5:
    - phpmyadmin:apache
    - port: 8080
    - [Documentação](https://hub.docker.com/_/phpmyadmin)
    
No momento da pesquisa dos containers, encontrei uma referência ao [Bind9.yaml](https://git.launchpad.net/~ubuntu-docker-images/ubuntu-docker-images/+git/bind9/plain/examples/bind9-deployment.yml?h=9.18-22.04) com arquivo de deployment e service, por isso, fiz dois arquivos um com service e outro sem service, como não tivemos esta aula ainda.  \
[Arquivo sem Services, licaoCasa.yaml](./licaoCasa.yaml)\
[Arquivo com Services, licaoCasaService.yaml](./licaoCasaService.yaml)\
[Arquivo Mono deployment, licaoCasaMono.yaml](./licaoCasaMono.yaml)\
Nele e em outros exemplos de arquivo Deployment, vi vários serviços juntos separados apenas por `---`. resolvi testar para o namespace e para os deployments.
```
apiVersion: v1
kind: Namespace
metadata:
  labels:
    kubernetes.io/metadata.name: server
  name: server
spec:
  finalizers:
  - kubernetes
status:
  phase: Active
--- 
apiVersion: apps/v1
kind: Deployment
```
Como não gostaria que um serviço influencie no outro, pensei em criar 4 deployments diferentes, mas fiz um teste de tudo no mesmo pod no arquivo mono \

## Aplicando arquivo licaoCasa.yaml
`$ kubectl apply -f ./licaoCasa.yaml`
```
namespace/server created
deployment.apps/httpd-deployment created
deployment.apps/bind9-deployment created
deployment.apps/mongo-deployment created
deployment.apps/mysql-deployment created
deployment.apps/phpmyadmin-deployment created`
```
`$ kubectl get pods -n server`
```
NAME                                     READY   STATUS             RESTARTS      AGE
bind9-deployment-59ff5fbf84-76wns        1/1     Running            0             2m42s
httpd-deployment-598d9f564d-62rnm        1/1     Running            0             2m42s
httpd-deployment-598d9f564d-9n965        1/1     Running            0             2m42s
httpd-deployment-598d9f564d-g6dk8        1/1     Running            0             2m42s
mongo-deployment-7f588dfc47-f2pd6        0/1     ImagePullBackOff   0             2m42s
mysql-deployment-76c6698496-k6774        0/1     CrashLoopBackOff   4 (43s ago)   2m42s
mysql-deployment-76c6698496-zjphq        0/1     CrashLoopBackOff   4 (43s ago)   2m42s
phpmyadmin-deployment-56dbc995c8-8ztn4   0/1     ImagePullBackOff   0             2m42s
```
- Problemas:
    - Mongo: `ImagePullBackOff` foi resolvido modificando a versão solicitada, alterada para `7-jammy`. 
    - PhpMyadmin: `ImagePullBackOff` foi resolvido modificando a versão solicitada, alterada para `apache`
    - Mysql: `CrashLoopBackOff` 
```
$ kubectl logs -n server mysql-deployment-ffc87888-ccl72 
2025-12-09 17:01:47+00:00 [Note] [Entrypoint]: Entrypoint script for MySQL Server 8.0.44-1debian12 started.
2025-12-09 17:01:47+00:00 [Note] [Entrypoint]: Switching to dedicated user 'mysql'
2025-12-09 17:01:47+00:00 [Note] [Entrypoint]: Entrypoint script for MySQL Server 8.0.44-1debian12 started.
2025-12-09 17:01:47+00:00 [ERROR] [Entrypoint]: Database is uninitialized and password option is not specified
    You need to specify one of the following as an environment variable:
    - MYSQL_ROOT_PASSWORD
    - MYSQL_ALLOW_EMPTY_PASSWORD
    - MYSQL_RANDOM_ROOT_PASSWORD
```
Solução: 
```
env:
- name: MYSQL_ROOT_PASSWORD
    value: "s3cr3tP@ssw0rd"
```
Resultado:
```
$ kubectl get pods -n server
NAME                                     READY   STATUS    RESTARTS   AGE
bind9-deployment-59ff5fbf84-vw4vl        0/1     Running   0          5s
httpd-deployment-598d9f564d-9bl5n        0/1     Running   0          5s
httpd-deployment-598d9f564d-nfljf        0/1     Running   0          5s
httpd-deployment-598d9f564d-tfw9t        0/1     Running   0          5s
mongo-deployment-6b76f9d4b-5kwzj         0/1     Running   0          5s
mysql-deployment-6975cc94b-k6dmm         0/1     Running   0          5s
mysql-deployment-6975cc94b-qn485         0/1     Running   0          5s
phpmyadmin-deployment-7d74d559cb-77lzg   0/1     Running   0          5s
```

## Aplicando licaoCasaMono.yaml
```
$ kubectl apply -f ./licaoCasaMono.yaml
namespace/server created
deployment.apps/httpd-deployment created
```
Resultado: 
```
$ kubectl get pods -n server
NAME                                READY   STATUS             RESTARTS      AGE
httpd-deployment-74bc958589-88bjn   3/5     CrashLoopBackOff   2 (22s ago)   42s
httpd-deployment-74bc958589-jkscn   3/5     CrashLoopBackOff   2 (22s ago)   42s
httpd-deployment-74bc958589-q6wrt   3/5     CrashLoopBackOff   2 (19s ago)   42s
```
Verificando erro:
```
$ kubectl logs -n server httpd-deployment-74bc958589-88bjn 
Defaulted container "httpd" out of: httpd, bind9, mongo, mysql, phpmyadmin
AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using 10.244.1.42. Set the 'ServerName' directive globally to suppress this message
AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using 10.244.1.42. Set the 'ServerName' directive globally to suppress this message
[Tue Dec 09 17:13:51.879950 2025] [mpm_event:notice] [pid 1:tid 1] AH00489: Apache/2.4.66 (Unix) configured -- resuming normal operations
[Tue Dec 09 17:13:51.880019 2025] [core:notice] [pid 1:tid 1] AH00094: Command line: 'httpd -D FOREGROUND'
10.244.1.1 - - [09/Dec/2025:17:14:01 +0000] "GET / HTTP/1.1" 200 191
10.244.1.1 - - [09/Dec/2025:17:14:11 +0000] "GET / HTTP/1.1" 200 191
10.244.1.1 - - [09/Dec/2025:17:14:11 +0000] "GET / HTTP/1.1" 200 191
```
Como tem dois apaches no mesmo servidor, ele não vai conseguir. Preferi tirar o phpmyadmin e funcionou:
```
$ kubectl get pods -n server
NAME                                READY   STATUS    RESTARTS   AGE
httpd-deployment-7b5fdcffff-vxdlq   0/4     Running   0          3s

$ kubectl get pods -n server
NAME                                READY   STATUS    RESTARTS   AGE
httpd-deployment-7b5fdcffff-vxdlq   4/4     Running   0          7m40s
```