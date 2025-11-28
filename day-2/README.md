# Resumo de comandos e explicações day-2


`$ kubectl exec -ti strigus -- bash`
- exec - executar comando dentro do container|pod\
- ti - libera o terminal\
- -- separa o comando que deve ser executado, neste caso bash, para liberar linha de comando\

`$ kubectl attach alpine -c alpine -it`
- attach - atribui o mando que desejar\

`$ kubectl apply -f podAlpine.yaml `
- apply - vai montar ou recarregar com alterações, exceto para novos containers, neste caso precisa deletar e aplicar novamente.\
- -f através de um arquivo\

`$ kubectl get pods -w -o wide|yaml`
- get - verifica os itens montados\
- pods|nodes|resouces|deployments|all - tipo que deseja verificar\
- -w mantem o status atualizado\
- -o tipo de saída wide|yaml|json\
  - wide - expõe o IP\

`$ kubectl describe pods`
- describe - descreve todos os elementos e cenários\
- pods|nodes|all\

`$ kubectl logs <name> -c <containerName> -f`
- logs - verifica o log \
- -c - container\
- -f - mantem status atualizado\

## inserindo limites
no yaml adiciona as linhas \
```
    resources:
      limits:
        cpu: "0.5"
        memory: "128Mi"
      requests:
        cpu: "0.3"
        memory: "64Mi"
```
usa o stress para testar o uso\
install stress\
`stress --cpu 1 --vm 1 --vm-bytes 100M --timeout 10s`


