# Day 5 - Cluster kubernetes
Baseado no documento [https://github.com/badtuxx/CertifiedContainersExpert/tree/main/DescomplicandoKubernetes/day-5](badtuxx), com adaprtações para aplicação com arm rasopberry pi.\

- O que é um cluster kubernetes:\
Conjunto de máquinas, nodes, VMs que compõem um cluster.\
Sua principal função é orquestrar containers.\
é divido em:
- Control plane - cerebro do cluster, decide onde cada item será instalado,  gerencia redes. Composto basicamente por:
    - namespaces, 
    - deployments, 
    - services, 
    - api-services,
    - configmaps, 
    - secrets,
    - scheduler,
    - etcd,
    - controller-manager,
    - 
    - etc.
- Workers - cuida dos pods, verifica a saúde
\
\
- Formas de montar um cluster
    - kubeadm: É uma ferramenta para criar e gerenciar um cluster Kubernetes em vários nós. Ele automatiza muitas das tarefas de configuração do cluster, incluindo a instalação do control plane e dos nodes. É altamente configurável e pode ser usado para criar clusters personalizados.
    - Kubespray: É uma ferramenta que usa o Ansible para implantar e gerenciar um cluster Kubernetes em vários nós. Ele oferece muitas opções para personalizar a instalação do cluster, incluindo a escolha do provedor de rede, o número de réplicas do control plane, o tipo de armazenamento e muito mais. É uma boa opção para implantar um cluster em vários ambientes, incluindo nuvens públicas e privadas.
    - Cloud Providers: Muitos provedores de nuvem, como AWS, Google Cloud Platform e Microsoft Azure, oferecem opções para implantar um cluster Kubernetes em sua infraestrutura. Eles geralmente fornecem modelos predefinidos que podem ser usados para implantar um cluster com apenas alguns cliques. Alguns provedores de nuvem também oferecem serviços gerenciados de Kubernetes que lidam com toda a configuração e gerenciamento do cluster.
    - Kubernetes Gerenciados: São serviços gerenciados oferecidos por alguns provedores de nuvem, como Amazon EKS, o GKE do Google Cloud e o AKS, da Azure. Eles oferecem um cluster Kubernetes gerenciado onde você só precisa se preocupar em implantar e gerenciar seus aplicativos. Esses serviços lidam com a configuração, atualização e manutenção do cluster para você. Nesse caso, você não tem que gerenciar o control plane do cluster, pois ele é gerenciado pelo provedor de nuvem.
    - Kops: É uma ferramenta para implantar e gerenciar clusters Kubernetes na nuvem. Ele foi projetado especificamente para implantação em nuvens públicas como AWS, GCP e Azure. Kops permite criar, atualizar e gerenciar clusters Kubernetes na nuvem. Algumas das principais vantagens do uso do Kops são a personalização, escalabilidade e segurança. No entanto, o uso do Kops pode ser mais complexo do que outras opções de instalação do Kubernetes, especialmente se você não estiver familiarizado com a nuvem em que está implantando.
    - Minikube e kind: São ferramentas que permitem criar um cluster Kubernetes localmente, em um único nó. São úteis para testar e aprender sobre o Kubernetes, pois você pode criar um cluster em poucos minutos e começar a implantar aplicativos imediatamente. Elas também são úteis para pessoas desenvolvedoras que precisam testar suas aplicações em um ambiente Kubernetes sem precisar configurar um cluster em um ambiente de produção.

- Recomendações:
    - 2GB RAM
    - 2 CPU ou mais
    Algumas portas precisam estar abertas para que o cluster funcione corretamente, as principais:

    * Porta 6443: É a porta padrão usada pelo Kubernetes API Server para se comunicar com os componentes do cluster. É a porta principal usada para gerenciar o cluster e deve estar sempre aberta.

    * Portas 10250-10255: Essas portas são usadas pelo kubelet para se comunicar com o control plane do Kubernetes. A porta 10250 é usada para comunicação de leitura/gravação e a porta 10255 é usada apenas para comunicação de leitura.

    * Porta 30000-32767: Essas portas são usadas para serviços NodePort que precisam ser acessíveis fora do cluster. O Kubernetes aloca uma porta aleatória dentro desse intervalo para cada serviço NodePort e redireciona o tráfego para o pod correspondente.

    * Porta 2379-2380: Essas portas são usadas pelo etcd, o banco de dados de chave-valor distribuído usado pelo control plane do Kubernetes. A porta 2379 é usada para comunicação de leitura/gravação e a porta 2380 é usada apenas para comunicação de eleição.



##### Desativando o uso do swap no sistema

Primeiro, vamos desativar a utilização de swap no sistema. Isso é necessário porque o Kubernetes não trabalha bem com swap ativado:

```
sudo swapoff -a
```

no raspberrypi: [https://www.webwhitenoise.com/p/disable-swap-on-raspberry-pi-os-trixie](https://www.webwhitenoise.com/p/disable-swap-on-raspberry-pi-os-trixie)

```
sudo service rpi-setup-loop@var-swap stop
```
Install watchdog: [https://medium.com/@arslion/enabling-watchdog-on-raspberry-pi-b7e574dcba6b](https://medium.com/@arslion/enabling-watchdog-on-raspberry-pi-b7e574dcba6b)



##### Carregando os módulos do kernel

Agora, vamos carregar os módulos do kernel necessários para o funcionamento do Kubernetes:

```
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter
```

##### Configurando parâmetros do sistema

Em seguida, vamos configurar alguns parâmetros do sistema. Isso garantirá que nosso cluster funcione corretamente:

```
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system
```

##### Instalando os pacotes do Kubernetes

Hora de instalar os pacotes do Kubernetes! Coisa linda de ai meu Deus! Aqui vamos nós:

```
sudo apt update && sudo apt install apt-transport-https ca-certificates gnupg curl -y

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.34/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.34/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl

sudo apt-mark hold kubelet kubeadm kubectl
```

##### Instalando o containerd

Em seguida, vamos instalar o containerd, que são essenciais para nosso ambiente Kubernetes PC Normal:

```
sudo apt-get update && sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update && sudo apt-get install -y containerd.io
```
para raspberry PI
```
sudo apt update && sudo apt upgrade -y
sudo apt install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io
```

##### Configurando o containerd

Agora, vamos configurar o containerd para que ele funcione adequadamente com o nosso cluster:

```
sudo containerd config default | sudo tee /etc/containerd/config.toml

sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml

sudo systemctl restart containerd
sudo systemctl status containerd
```

##### Habilitando o serviço do kubelet

Por fim, vamos habilitar o serviço do kubelet para que ele inicie automaticamente com o sistema:

```
sudo systemctl enable --now kubelet
```

##### Configurando as portas

Antes de iniciar o cluster, lembre-se das portas que precisam estar abertas para que o cluster funcione corretamente. Precisamos ter as portas TCP 6443, 10250-10255, 30000-32767 e 2379-2380 abertas entre os nodes do cluster. No nosso exemplo, onde estaremos usando somente um node `control plane`, não precisamos nos preocupar com algumas quando temos mais de um node `control plane`, pois eles precisam se comunicar entre si para manter o estado do cluster, ou ainda as portas 30000-32767, que são usadas para serviços NodePort que precisam ser acessíveis fora do cluster. Elas nós podemos ir abrindo conforme a necessidade, conforme vamos criando os nossos serviços.

Por agora o que precisamos garantir são as portas TCP 6443 somente no `control plane` e as 10250-10255 abertas em todos nodes do cluster.

Em nosso exemplo vamos utilizar como CNI o Weave Net, que é um CNI que utiliza o protocolo de roteamento de pacotes do Kubernetes para criar uma rede entre os pods. Falarei mais sobre ele mais pra frente, mas como estamos falando das portas que são importantes para o cluster funcionar, precisamos abrir a porta TCP 6783 e as portas UDP 6783 e 6784, para que o Weave Net funcione corretamente.

Então já sabe, não esqueça de abrir as portas TCP 6443, 10250-10255 e 6783 no seu firewall.

##### Inicializando o cluster

Agora que temos tudo configurado, vamos iniciar o nosso cluster:

```
sudo kubeadm init --pod-network-cidr=10.10.0.0/16 --apiserver-advertise-address=<O IP QUE VAI FALAR COM OS NODES>
```

&nbsp;


Substitua `<O IP QUE VAI FALAR COM OS NODES>` pelo endereço IP da máquina que está atuando como `control plane`.

Após a execução bem-sucedida do comando acima, você verá uma mensagem informando que o cluster foi inicializado com sucesso e todos os detalhes de sua inicialização, conforme é possível ver na saída do comando:

```bash
[init] Using Kubernetes version: v1.26.3
[preflight] Running pre-flight checks
[preflight] Pulling images required for setting up a Kubernetes cluster
[preflight] This might take a minute or two, depending on the speed of your internet connection
[preflight] You can also perform this action in beforehand using 'kubeadm config images pull'
[certs] Using certificateDir folder "/etc/kubernetes/pki"
[certs] Generating "ca" certificate and key
[certs] Generating "apiserver" certificate and key
[certs] apiserver serving cert is signed for DNS names [k8s-01 kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [10.96.0.1 172.31.57.89]
[certs] Generating "apiserver-kubelet-client" certificate and key
[certs] Generating "front-proxy-ca" certificate and key
[certs] Generating "front-proxy-client" certificate and key
[certs] Generating "etcd/ca" certificate and key
[certs] Generating "etcd/server" certificate and key
[certs] etcd/server serving cert is signed for DNS names [k8s-01 localhost] and IPs [172.31.57.89 127.0.0.1 ::1]
[certs] Generating "etcd/peer" certificate and key
[certs] etcd/peer serving cert is signed for DNS names [k8s-01 localhost] and IPs [172.31.57.89 127.0.0.1 ::1]
[certs] Generating "etcd/healthcheck-client" certificate and key
[certs] Generating "apiserver-etcd-client" certificate and key
[certs] Generating "sa" key and public key
[kubeconfig] Using kubeconfig folder "/etc/kubernetes"
[kubeconfig] Writing "admin.conf" kubeconfig file
[kubeconfig] Writing "kubelet.conf" kubeconfig file
[kubeconfig] Writing "controller-manager.conf" kubeconfig file
[kubeconfig] Writing "scheduler.conf" kubeconfig file
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Starting the kubelet
[control-plane] Using manifest folder "/etc/kubernetes/manifests"
[control-plane] Creating static Pod manifest for "kube-apiserver"
[control-plane] Creating static Pod manifest for "kube-controller-manager"
[control-plane] Creating static Pod manifest for "kube-scheduler"
[etcd] Creating static Pod manifest for local etcd in "/etc/kubernetes/manifests"
[wait-control-plane] Waiting for the kubelet to boot up the control plane as static Pods from directory "/etc/kubernetes/manifests". This can take up to 4m0s
[apiclient] All control plane components are healthy after 7.504091 seconds
[upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
[kubelet] Creating a ConfigMap "kubelet-config" in namespace kube-system with the configuration for the kubelets in the cluster
[upload-certs] Skipping phase. Please see --upload-certs
[mark-control-plane] Marking the node k8s-01 as control-plane by adding the labels: [node-role.kubernetes.io/control-plane node.kubernetes.io/exclude-from-external-load-balancers]
[mark-control-plane] Marking the node k8s-01 as control-plane by adding the taints [node-role.kubernetes.io/control-plane:NoSchedule]
[bootstrap-token] Using token: if9hn9.xhxo6s89byj9rsmd
[bootstrap-token] Configuring bootstrap tokens, cluster-info ConfigMap, RBAC Roles
[bootstrap-token] Configured RBAC rules to allow Node Bootstrap tokens to get nodes
[bootstrap-token] Configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
[bootstrap-token] Configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
[bootstrap-token] Configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
[bootstrap-token] Creating the "cluster-info" ConfigMap in the "kube-public" namespace
[kubelet-finalize] Updating "/etc/kubernetes/kubelet.conf" to point to a rotatable kubelet client certificate and key
[addons] Applied essential addon: CoreDNS
[addons] Applied essential addon: kube-proxy

Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 172.31.57.89:6443 --token if9hn9.xhxo6s89byj9rsmd \
	--discovery-token-ca-cert-hash sha256:ad583497a4171d1fc7d21e2ca2ea7b32bdc8450a1a4ca4cfa2022748a99fa477 

```
* erro no join do raspbian
```
$ sudo kubeadm join 192.168.0.150:6443 --token li3aej.ajg8jjyrwqlp08lw     --discovery-token-ca-cert-hash sha256:e76fcd6694b95018e180f9329391c542d5c3f6ae46c0d48988393a3c921190c2
[preflight] Running pre-flight checks
[preflight] The system verification failed. Printing the output from the verification:
KERNEL_VERSION: 6.12.47+rpt-rpi-v8
CONFIG_NAMESPACES: enabled
CONFIG_NET_NS: enabled
CONFIG_PID_NS: enabled
CONFIG_IPC_NS: enabled
CONFIG_UTS_NS: enabled
CONFIG_CGROUPS: enabled
CONFIG_CPUSETS: enabled
CONFIG_MEMCG: enabled
CONFIG_INET: enabled
CONFIG_EXT4_FS: enabled
CONFIG_PROC_FS: enabled
CONFIG_NETFILTER_XT_TARGET_REDIRECT: enabled (as module)
CONFIG_NETFILTER_XT_MATCH_COMMENT: enabled (as module)
CONFIG_FAIR_GROUP_SCHED: enabled
CONFIG_OVERLAY_FS: enabled (as module)
CONFIG_AUFS_FS: not set - Required for aufs.
CONFIG_BLK_DEV_DM: enabled (as module)
CONFIG_CFS_BANDWIDTH: enabled
CONFIG_SECCOMP: enabled
CONFIG_SECCOMP_FILTER: enabled
OS: Linux
CGROUPS_CPU: enabled
CGROUPS_CPUSET: enabled
CGROUPS_DEVICES: enabled
CGROUPS_FREEZER: enabled
CGROUPS_MEMORY: missing
CGROUPS_PIDS: enabled
CGROUPS_HUGETLB: missing
CGROUPS_IO: enabled
	[WARNING SystemVerification]: missing optional cgroups: hugetlb
[preflight] Some fatal errors occurred:
	[ERROR SystemVerification]: missing required cgroups: memory
[preflight] If you know what you are doing, you can make a check non-fatal with `--ignore-preflight-errors=...`
error: error execution phase preflight: preflight checks failed
To see the stack trace of this error execute with --v=5 or higher

```
Buscando erro do cgroups em foruns , encontrei o issue no git. \
Adicionando no arquivo /boot/firmware/cmdline.txt: `cgroup_memory=1 cgroup_enable=memory` \
Quando fui rodar o comando novamente, tinha vencido o token, então rodei o comando `kubeadm token create --print-join-command`\
retornou o comando: `sudo kubeadm join 192.168.0.150:6443 --token a30rqe.1k622wry075uuky6 --discovery-token-ca-cert-hash sha256:e76fcd6694b95018e180f9329391c542d5c3f6ae46c0d48988393a3c921190c2`\



&nbsp;

Inclusive, você verá uma lista de comandos para configurar o acesso ao cluster com o kubectl. Copie e cole esse comando em seu terminal:

```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

&nbsp;

Essa configuração é necessária para que o kubectl possa se comunicar com o cluster, pois quando estamos copiando o arquivo `admin.conf` para o diretório `.kube` do usuário, estamos copiando o arquivo com as permissões de root, esse é o motivo de executarmos o comando `sudo chown $(id -u):$(id -g) $HOME/.kube/config` para alterar as permissões do arquivo para o usuário que está executando o comando.



Caso você queira, você pode acessar o conteúdo do arquivo `admin.conf` com o seguinte comando:


```bash
kubectl config view
```

&nbsp;

Ele somente irá omitir os dados de certificados e chaves privadas, que são muito grandes para serem exibidos no terminal.

&nbsp;

##### Adicionando os demais nodes ao cluster

Agora que já temos o nosso cluster inicializado e já estamos entendendo muito bem o que é o arquivo `admin.conf`, chegou o momento de adicionar os demais nodes ao nosso cluster.

Para isso, vamos novamente utilizar o comando `kubeadm`, porém ao invés de executar o comando no node do control plane, nesse momento precisamos rodar o comando diretamente no node que queremos adicionar ao cluster.

Quando inicializamos o nosso cluster, o `kubeadm` nos mostrou o comando que precisamos executar no novos nodes, para que eles possam ser adicinados ao cluster como `workers`.

```bash
sudo kubeadm join 172.31.57.89:6443 --token if9hn9.xhxo6s89byj9rsmd \
	--discovery-token-ca-cert-hash sha256:ad583497a4171d1fc7d21e2ca2ea7b32bdc8450a1a4ca4cfa2022748a99fa477 
```

&nbsp;

O comando kubeadm join é usado para adicionar um novo node ao cluster Kubernetes existente. Ele é executado nos worker nodes para que eles possam se juntar ao cluster e receber instruções do control plane. Vamos analisar as partes do comando fornecido:

- **kubeadm join**: O comando base para adicionar um novo nó ao cluster.

- **172.31.57.89:6443**: Endereço IP e porta do servidor de API do nó mestre (control plane). Neste exemplo, o nó mestre está localizado no IP 172.31.57.89 e a porta é 6443.

- **--token if9hn9.xhxo6s89byj9rsmd**: O token é usado para autenticar o nó trabalhador no nó mestre durante o processo de adesão. Os tokens são gerados pelo nó mestre e têm uma validade limitada (por padrão, 24 horas). Neste exemplo, o token é if9hn9.xhxo6s89byj9rsmd.

- **--discovery-token-ca-cert-hash sha256:ad583497a4171d1fc7d21e2ca2ea7b32bdc8450a1a4ca4cfa2022748a99fa477**: Este é um hash criptográfico do certificado da autoridade de certificação (CA) do control plane. Ele é usado para garantir que o nó worker esteja se comunicando com o nó do control plane correto e autêntico. O valor após sha256: é o hash do certificado CA.

Ao executar este comando no worker, ele iniciará o processo de adesão ao cluster. Se o token for válido e o hash do certificado CA corresponder ao certificado CA do nó do control plane, o nó worker será autenticado e adicionado ao cluster. Após a adesão bem-sucedida, o novo node começará a executar os Pods e a receber instruções do control plane, conforme necessário.

Após executar o `join` em cada worker node, vá até o node que criamos para ser o control plane, e execute:

```bash
kubectl get nodes
```

&nbsp;

```bash
NAME     STATUS   ROLES           AGE   VERSION
k8s-01   NotReady    control-plane   4m   v1.26.3
k8s-02   NotReady    <none>          3m   v1.26.3
k8s-03   NotReady    <none>          3m   v1.26.3
```

&nbsp;

Agora você já consegue ver que os dois novos nodes foram adicionados ao cluster, porém ainda estão com o status `Not Ready`, pois ainda não instalamos o nosso plugin de rede para que seja possível a comunicação entre os pods. Vamos resolver isso agora. :)

##### Instalando o Weave Net

Agora que o cluster está inicializado, vamos instalar o Weave Net:

```
$ kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml
```

&nbsp;

Aguarde alguns minutos até que todos os componentes do cluster estejam em funcionamento. Você pode verificar o status dos componentes do cluster com o seguinte comando:

```
kubectl get pods -n kube-system
```
&nbsp;

```
kubectl get nodes
```

&nbsp;

```bash
NAME     STATUS   ROLES           AGE   VERSION
k8s-01   Ready    control-plane   7m   v1.26.3
k8s-02   Ready    <none>          6m   v1.26.3
k8s-03   Ready    <none>          6m   v1.26.3
```

&nbsp;

O Weave Net é um plugin de rede que permite que os pods se comuniquem entre si. Ele também permite que os pods se comuniquem com o mundo externo, como outros clusters ou a Internet. 
Quando o Kubernetes é instalado, ele resolve vários problemas por si só, porém quando o assunto é a comunicação entre os pods, ele não resolve. Por isso, precisamos instalar um plugin de rede para resolver esse problema.

##### O que é o CNI?

CNI é uma especificação e conjunto de bibliotecas para a configuração de interfaces de rede em containers. A CNI permite que diferentes soluções de rede sejam integradas ao Kubernetes, facilitando a comunicação entre os Pods (grupos de containers) e serviços.

Com isso, temos diferentes plugins de redes, que seguem a especificação CNI, e que podem ser utilizados no Kubernetes. O Weave Net é um desses plugins de rede.

Entre os plugins de rede mais utilizados no Kubernetes, temos:

- **Calico** é um dos plugins de rede mais populares e amplamente utilizados no Kubernetes. Ele fornece segurança de rede e permite a implementação de políticas de rede. O Calico utiliza o BGP (Border Gateway Protocol) para rotear tráfego entre os nós do cluster, proporcionando um desempenho eficiente e escalável.

- **Flannel** é um plugin de rede simples e fácil de configurar, projetado para o Kubernetes. Ele cria uma rede overlay que permite que os Pods se comuniquem entre si, mesmo em diferentes nós do cluster. O Flannel atribui um intervalo de IPs a cada nó e utiliza um protocolo simples para rotear o tráfego entre os nós.

- **Weave** é outra solução popular de rede para Kubernetes. Ele fornece uma rede overlay que permite a comunicação entre os Pods em diferentes nós. Além disso, o Weave suporta criptografia de rede e gerenciamento de políticas de rede. Ele também pode ser integrado com outras soluções, como o Calico, para fornecer recursos adicionais de segurança e políticas de rede.

- **Cilium** é um plugin de rede focado em segurança e desempenho. Ele utiliza o BPF (Berkeley Packet Filter) para fornecer políticas de rede e segurança de alto desempenho. O Cilium também oferece recursos avançados, como balanceamento de carga, monitoramento e solução de problemas de rede.

- **Kube-router** é uma solução de rede leve para Kubernetes. Ele utiliza o BGP e IPVS (IP Virtual Server) para rotear o tráfego entre os nós do cluster, proporcionando um desempenho eficiente e escalável. Kube-router também suporta políticas de rede e permite a implementação de firewalls entre os Pods.

Esses são apenas alguns dos plugins de rede mais populares e amplamente utilizados no Kubernetes. Você pode encontrar uma lista completa de plugins de rede no site do Kubernetes.

Agora, qual você deverá escolher? A resposta é simples: o que melhor se adequar às suas necessidades. Cada plugin de rede tem suas vantagens e desvantagens, e você deve escolher aquele que melhor se adequar ao seu ambiente.

Minha dica, procure não ficar inventando muita moda, tenta utilizar os que são já validados e bem aceitos pela comunidade, como o Weave Net, Calico, Flannel, etc. 

O meu preferido é o `Weave Net` pela simplicidade de instalação e os recursos oferecidos.

Um cara que eu tenho gostado bastante é o `Cilium`, ele é bem completo e tem uma comunidade bem ativa, além de utilizar o BPF, que é um assunto super quente no mundo Kubernetes!

&nbsp;

Pronto, já temos o nosso cluster inicializado e o Weave Net instalado. Agora, vamos criar um Deployment para testar a comunicação entre os Pods.

```bash
kubectl create deployment nginx --image=nginx --replicas 3
```

&nbsp;

```bash
kubectl get pods -o wide
```

&nbsp;

```bash
NAME                     READY   STATUS    RESTARTS   AGE   IP          NODE     NOMINATED NODE   READINESS GATES
nginx-748c667d99-8brrj   1/1     Running   0          12s   10.32.0.4   k8s-02   <none>           <none>
nginx-748c667d99-8knx2   1/1     Running   0          12s   10.40.0.2   k8s-03   <none>           <none>
nginx-748c667d99-l6w7r   1/1     Running   0          12s   10.40.0.1   k8s-03   <none>           <none>
```

&nbsp;

Pronto, nosso cluster está funcionando e os Pods estão em execução em diferentes nós.

Agora você já pode se divertir e utilizar o seu mais novo cluster Kubernetes!

&nbsp;


#### Visualizando detalhes dos nodes

Agora que já temos o nosso clustes com 03 nodes, nós podemos visualizar os detalhes de cada um deles, e assim entender cada detalhe.

Para ver a descrição do node, basta executar o comando abaixo:

```bash
kubectl describe node k8s-01
```

&nbsp;

```bash
Name:               k8s-01
Roles:              control-plane
Labels:             beta.kubernetes.io/arch=amd64
                    beta.kubernetes.io/os=linux
                    kubernetes.io/arch=amd64
                    kubernetes.io/hostname=k8s-01
                    kubernetes.io/os=linux
                    node-role.kubernetes.io/control-plane=
                    node.kubernetes.io/exclude-from-external-load-balancers=
Annotations:        kubeadm.alpha.kubernetes.io/cri-socket: unix:///var/run/containerd/containerd.sock
                    node.alpha.kubernetes.io/ttl: 0
                    volumes.kubernetes.io/controller-managed-attach-detach: true
CreationTimestamp:  Fri, 07 Apr 2023 11:52:46 +0000
Taints:             node-role.kubernetes.io/control-plane:NoSchedule
Unschedulable:      false
Lease:
  HolderIdentity:  k8s-01
  AcquireTime:     <unset>
  RenewTime:       Fri, 07 Apr 2023 12:49:09 +0000
Conditions:
  Type                 Status  LastHeartbeatTime                 LastTransitionTime                Reason                       Message
  ----                 ------  -----------------                 ------------------                ------                       -------
  NetworkUnavailable   False   Fri, 07 Apr 2023 11:57:03 +0000   Fri, 07 Apr 2023 11:57:03 +0000   WeaveIsUp                    Weave pod has set this
  MemoryPressure       False   Fri, 07 Apr 2023 12:48:25 +0000   Fri, 07 Apr 2023 11:52:45 +0000   KubeletHasSufficientMemory   kubelet has sufficient memory available
  DiskPressure         False   Fri, 07 Apr 2023 12:48:25 +0000   Fri, 07 Apr 2023 11:52:45 +0000   KubeletHasNoDiskPressure     kubelet has no disk pressure
  PIDPressure          False   Fri, 07 Apr 2023 12:48:25 +0000   Fri, 07 Apr 2023 11:52:45 +0000   KubeletHasSufficientPID      kubelet has sufficient PID available
  Ready                True    Fri, 07 Apr 2023 12:48:25 +0000   Fri, 07 Apr 2023 11:57:05 +0000   KubeletReady                 kubelet is posting ready status. AppArmor enabled
Addresses:
  InternalIP:  172.31.57.89
  Hostname:    k8s-01
Capacity:
  cpu:                2
  ephemeral-storage:  7941576Ki
  hugepages-2Mi:      0
  memory:             4015088Ki
  pods:               110
Allocatable:
  cpu:                2
  ephemeral-storage:  7318956430
  hugepages-2Mi:      0
  memory:             3912688Ki
  pods:               110
System Info:
  Machine ID:                 c8a6ad1dd24342c48ba303688d3ada1f
  System UUID:                ec2b271b-8df3-f164-b01c-3b5078a2d15b
  Boot ID:                    93ae6b0c-13fa-432d-b15a-d3725b6c0e72
  Kernel Version:             5.15.0-1031-aws
  OS Image:                   Ubuntu 22.04.2 LTS
  Operating System:           linux
  Architecture:               amd64
  Container Runtime Version:  containerd://1.6.20
  Kubelet Version:            v1.26.3
  Kube-Proxy Version:         v1.26.3
PodCIDR:                      10.10.0.0/24
PodCIDRs:                     10.10.0.0/24
Non-terminated Pods:          (6 in total)
  Namespace                   Name                              CPU Requests  CPU Limits  Memory Requests  Memory Limits  Age
  ---------                   ----                              ------------  ----------  ---------------  -------------  ---
  kube-system                 etcd-k8s-01                       100m (5%)     0 (0%)      100Mi (2%)       0 (0%)         56m
  kube-system                 kube-apiserver-k8s-01             250m (12%)    0 (0%)      0 (0%)           0 (0%)         56m
  kube-system                 kube-controller-manager-k8s-01    200m (10%)    0 (0%)      0 (0%)           0 (0%)         56m
  kube-system                 kube-proxy-skpfc                  0 (0%)        0 (0%)      0 (0%)           0 (0%)         56m
  kube-system                 kube-scheduler-k8s-01             100m (5%)     0 (0%)      0 (0%)           0 (0%)         56m
  kube-system                 weave-net-hks8s                   100m (5%)     0 (0%)      0 (0%)           0 (0%)         52m
Allocated resources:
  (Total limits may be over 100 percent, i.e., overcommitted.)
  Resource           Requests    Limits
  --------           --------    ------
  cpu                750m (37%)  0 (0%)
  memory             100Mi (2%)  0 (0%)
  ephemeral-storage  0 (0%)      0 (0%)
  hugepages-2Mi      0 (0%)      0 (0%)
Events:
  Type     Reason                   Age   From             Message
  ----     ------                   ----  ----             -------
  Normal   Starting                 56m   kube-proxy       
  Normal   Starting                 56m   kubelet          Starting kubelet.
  Warning  InvalidDiskCapacity      56m   kubelet          invalid capacity 0 on image filesystem
  Normal   NodeHasSufficientMemory  56m   kubelet          Node k8s-01 status is now: NodeHasSufficientMemory
  Normal   NodeHasNoDiskPressure    56m   kubelet          Node k8s-01 status is now: NodeHasNoDiskPressure
  Normal   NodeHasSufficientPID     56m   kubelet          Node k8s-01 status is now: NodeHasSufficientPID
  Normal   NodeAllocatableEnforced  56m   kubelet          Updated Node Allocatable limit across pods
  Normal   RegisteredNode           56m   node-controller  Node k8s-01 event: Registered Node k8s-01 in Controller
  Normal   NodeReady                52m   kubelet          Node k8s-01 status is now: NodeReady
```

&nbsp;

Na saída do comando acima é possível ver detalhes como o nome do node, o IP interno, o hostname, a capacidade de CPU, memória, armazenamento, pods, etc. Também é possível ver os pods que estão rodando no node, os recursos alocados e os eventos que ocorreram no node.

Caso você queira visualizar detalhes dos outros dois nodes, basta utilizar o comando abaixo:

```bash
kubectl get nodes k8s-02 -o wide
kubectl get nodes k8s-03 -o wide
```

&nbsp;

```bash
NAME     STATUS   ROLES    AGE   VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION    CONTAINER-RUNTIME
k8s-02   Ready    <none>   59m   v1.26.3   172.31.59.34   <none>        Ubuntu 22.04.2 LTS   5.15.0-1031-aws   containerd://1.6.20
```

&nbsp;


Estou utilizando o parâmetro `-o wide` para que o comando retorne mais detalhes sobre o node, como o IP externo e o IP interno.

E claro, você ainda pode utilizar o comando `kubectl describe node` para visualizar mais detalhes dos demais nodes, como fizemos para o node `k8s-01`.
