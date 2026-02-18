# Entrevistas com Jeferson de IA -  Parte 3

1 - me explica quando você prefere injetar configurações como variáveis de ambiente e quando é melhor montar um ConfigMap como volume no pod?
Na maioria dos casos é mais indicado utilizar ConfigMap para enviar arquivos de configuração de ambiente ou variáveis que serão utilizadas. Pois facilitam a manutenção e podem ser utilizados por vários pods com segurança e confiabilidade.
Mas, podemos injetar informações como env na image de criação do pod, como valores de host de banco de dados portas, enfim, dados menos restritos que não demandam segurança. 
2 - imagina que a gente precisa expor uma aplicação usando o Nginx Ingress Controller: qual a diferença técnica entre usar o roteamento baseado em path e o baseado em host, e como você configuraria o TLS pra esse Ingress usando uma Secret?
o roteamento baseado em path é aquele que utiliza as pasta e as terminações como /admin no pod nginx-admin ou /landing-page para o nginx-landing-page, onde os dois são aplicações distintas. Já o baseado em host, é definido pelo host que está sendo apontado para aquele pod ou deployment, ex. admin.carlosclaro.com.br ou landing-page.carlosclaro.com.br
criando chave tls com o comando:
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout chave-privada.key -out certificado.crt
e adicionando no arquivo kind secret através dos campos data.tls.crt e data.tls.key
3 - como você automatizaria a renovação desses certificados usando o Cert-Manager no Kubernetes e qual o papel das Annotations nesse processo dentro do seu arquivo de Ingress?
Após configurado um cluster-issuer  e indicado nas anotations, o cert-manager faz o auto gerenciamento dos certificados, os annotations tem o papel de indicar o privatekeysecretref que vai ser utilizado neste ingress para gerar o certificado. ex: cert-manager.io/cluster-issuer: cert-prod, podendo ser utilizado tambem cert-manager.io/issuer para testes e sandbox.