# Entrevistas com Jeferson de IA -  Parte 2

1 - qual a diferença prática entre requests e limits de CPU num Pod e o que acontece se o container tentar usar mais memória do que o limite definido?
Requests são valores de cpu e memória que o pod vai iniciar disponível e garantido e limits é o limite maximo que ele pode utilizar. Quando o container ou pod tenta utilizar mais que o limite estabelecido, gera um erro de OOMKilled out of memory killed.
2 - como você configuraria o maxSurge e o maxUnavailable num Deployment de estratégia RollingUpdate?
Levando em conta um deployment com 10 réplicas, buscaria sempre tratar no máximo 20% maxUnavailable: 2. e trocaria 10% por vez ou maxSurge: 1
Mantendo sempre uma boa quantidade de pods em pé enquanto atualiza
3 - me explica quando que eu devo usar uma Readiness Probe em vez de uma Liveness Probe e o que acontece se a Readiness falhar?
A liveness probe é a primeira a ser testada após o pod ser montado e é utilizada para testar se a aplicação dentro do pod está respondendo corretamente, pode ser através de uma resposta do software ou uma porta de comunicação disponível, podemos adicionar um initialDelaySeconds, para aguardar o primeiro teste e se falhar, irá reiniciar quantas vezes definirmos em failureThreshold, até informar um erro na montagem.
O Readiness Probe verifica se o container está pronto para receber requisições, como trafego externo, então vamos testar um service ou endpoint. o erro que retorna em caso de falha é readiness probe failed com statuscode, pode ser 404 ou 500 em caso de um nginx que busca um endpoint.