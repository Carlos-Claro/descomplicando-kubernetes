# Aula ao vivo 07/02

Realizando verificação de vulnerabilidade em dockerfile e suas dependências
Utilizando wolfi

`docker scout quickview `

KUBEBANK - SOLICITAÇÃO DE PROPOSTA TÉCNICA (RFP)

Objetivo: Definir a arquitetura de segurança e observabilidade da aplicação CashFlow API no cluster Kubernetes.
Instruções: O grupo deve discutir e responder às perguntas abaixo, justificando as escolhas técnicas com base no conteúdo do curso (Day-1 ao Day-13).

SEÇÃO 1: SEGURANÇA DA CADEIA DE SUPRIMENTOS (Focus: Day 13) A equipe de segurança barrou a imagem atual baseada em ubuntu:latest pois ela tem muitas CVEs.
Qual Imagem Base vocês recomendam para reduzir a superfície de ataque ao máximo (Ex: Alpine, Debian-slim, Wolfi/Distroless)? Por que?
Quais ferramentas devemos rodar no pipeline de CI/CD para garantir que não estamos subindo vulnerabilidades críticas (Ex: Trivy, Docker Scout)?
Como garantir a integridade da imagem no cluster, assegurando que ela foi assinada pela nossa equipe? (Ex: Cosign).

SEÇÃO 2: ESTRATÉGIA DE ACESSO (Focus: Day 9 & 10) O Banco Central exige criptografia em trânsito para qualquer acesso externo.
Como vamos expor esse serviço para a internet? (Service LoadBalancer ou Ingress?) Qual Controller sugerem (Nginx, Traefik)?
Precisamos de HTTPS. Como vamos gerenciar os certificados TLS de forma automatizada? (Ex: Cert-Manager com Let's Encrypt).
Qual objeto do Kubernetes precisamos criar para definir as regras de roteamento (host, path)?

SEÇÃO 3: OBSERVABILIDADE TOTAL (Focus: Day 11 & 12) A equipe de Ops usa a stack Prometheus (Kube-Prometheus-Stack).
A aplicação expõe métricas na porta /metrics. O que precisamos criar no Kubernetes (CRD) para que o Prometheus descubra e comece a "raspar" (scrape) esses dados automaticamente? (ServiceMonitor ou PodMonitor?)
Se a aplicação começar a falhar, qual componente da stack de monitoramento (Alertmanager) vai nos avisar?

SEÇÃO 4: RESILIÊNCIA E DISPONIBILIDADE (Focus: Day 6 & 8)
A aplicação consome muita memória na inicialização. O que devemos configurar no manifesto do Pod para evitar o OOMKill (Out of Memory)?
A aplicação demora 30 segundos para iniciar a conexão com o banco de dados. Qual Probe devemos configurar para evitar que o Kubernetes mande tráfego antes dela estar pronta? (Liveness, Readiness ou Startup?)




links:
https://images.chainguard.dev/
https://github.com/GoogleContainerTools/distroless
https://docs.docker.com/scout/quickstart
cyclonedx-org
https://app.fireflies.ai/live/01KGMP12WN4CP7HMX10HWJ5SHP?ref=live_chat
