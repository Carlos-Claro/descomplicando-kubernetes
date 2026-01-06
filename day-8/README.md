# Day 8

Referência:
[https://github.com/badtuxx/CertifiedContainersExpert/tree/main/DescomplicandoKubernetes/day-8](https://github.com/badtuxx/CertifiedContainersExpert/tree/main/DescomplicandoKubernetes/day-8)

## Secret ([Documentação](https://kubernetes.io/docs/concepts/configuration/secret))
Forma de armazenar tokens ou senhas no k8s ou em pods.\
Local: etcd\
Segurança: não criptografado por default, apenas base64\
Criando conteúdo base64 no linux `echo -n 'giropops' | base64`\
para retornar, apenas inclua -d no final.

`k exec -ti pod-secret -- env`

criando chave tls

`openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout chave-privada.key -out certificado.crt`

criando secret por linha de comando
`create secret tls meu-tls-secret --cert=certificado.crt --key=chave-privada.key`

liberando portas:
`kubectl port-forward services/pod-configmap 4443:443`