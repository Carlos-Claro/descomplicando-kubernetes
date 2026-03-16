# Day 16 - Taints, Labels, Toleration e Affinity


## Taints
São marcas que são colocadas nos Nodes, utilizado para isolar os nós. Gerencia as preferencias e disponibilidade. 

Os Taints são aplicados nos Nodes e podem ter um efeito de NoSchedule, PreferNoSchedule ou NoExecute. O efeito NoSchedule faz com que o Kubernetes não agende Pods nesse Node a menos que eles tenham uma Toleration correspondente. O efeito PreferNoSchedule faz com que o Kubernetes tente não agendar, mas não é uma garantia. E o efeito NoExecute faz com que os Pods existentes sejam removidos se não tiverem uma Toleration correspondente.

Verificar os nodes disponíveis: `k describe nodes pc-x-control-plane `

### NoExecute
não vai enviar pods para este nó
cria taint `k taint node manutencao=true:NoExecute`
retira taint `k taint node dell-x-worker manutencao=true:NoExecute-`
Redistribuindo `k rollout restart deployment nginx`

### NoSchedule
Não adicionar nada novo 
cria taint `k taint node gpu=true:NoSchedule`

/[]
### Toleration
Agora que entendemos como os Taints funcionam e como eles influenciam o agendamento de Pods nos Nodes, vamos mergulhar no mundo das Tolerations. As Tolerations são como o "antídoto" para os Taints. Elas permitem que um Pod seja agendado em um Node que possui um Taint específico. Em outras palavras, elas "toleram" as Taints. \
veja arquivo [deployment-nginx-gpu.yaml](deployment-nginx-gpu.yaml)

## Affinity
Affinity e Antiaffinity são conceitos que permitem que você defina regras para o agendamento de Pods em determinados Nodes. Com eles você pode definir regras para que Pods sejam agendados em Nodes específicos, ou até mesmo para que Pods não sejam agendados em Nodes específicos.
Utilizado para distribuir os pods no cluster, definindo o local através de labels.

veja arquivo [deployment-nginx-affinity.yaml](deployment-nginx-affinity.yaml)

`k label nodes prog-x-worker region=esquerda`
`k label nodes dell-x-worker region=direita`
`k label nodes prog-x-worker az=a1`
`k label nodes dell-x-worker az=a2`
`k get nodes dell-x-worker --show-labels`
`k get nodes -L region`

## AntiAffinity

[deployment-nginx-antiaffinity.yaml](deployment-nginx-antiaffinity.yaml)