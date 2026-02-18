# Entrevistas com Jeferson de IA

1 -  me explica aí com as suas palavras qual a principal diferença prática entre rodar um app num container e rodar numa máquina virtual.
Em uma maquina virtual estamos mais vulneráveis a erros de versão entre o ambiente de desenvolvimento e produção, pois cada desenvolvedor pode estar com diferentes versões de plugins ou ferramentas que compõem a aplicação, o famoso, "na minha maquina funciona" do ambiente de desenvolvimento e o ambiente de produção. Já no Container tudo fica mais organizado e todos usam o mesmo container com a versão padrão.
2 - qual a principal diferença entre o papel do Control Plane e o papel dos Workers no cluster?
O control plane é responsável pelas tarefas de organização, comunicação, configurações, vai definir os melhores caminhos para requisição, trabalhar a comunicação com load balancer.
Os workers tem a responsabilidade de montar os pods e os containers e organizar da melhor forma para receber as requisições.
3 -  se eu te pedir pra criar um Pod rapidinho via linha de comando, sem arquivo nenhum, só pra testar um container de Nginx, qual comando do kubectl você usaria e qual parâmetro colocaria pra ver o YAML dele na tela sem criar nada de fato?
kubectl run pod 