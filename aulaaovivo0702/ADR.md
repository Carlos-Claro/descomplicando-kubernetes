# ADR kubebank

## SEÇÃO 1: SEGURANÇA DA CADEIA DE SUPRIMENTOS
- Solução atual: ubuntu:latest
```
# Dockerfile 
FROM ubuntu:latest

WORKDIR /app

RUN apt-get update && apt-get install -y python3 python3-pip

COPY  app/main.py app/
ENTRYPOINT [ "python", "main.py" ]
```
Resultado `docker images`
```
REPOSITORY     TAG             IMAGE ID       CREATED          SIZE
carlosclaro    kubebank1.0     8308e2611694   15 seconds ago   578MB
```
A imagem muito grande, com itens que não utilizamos e muitas CVE High `docker scout quickview kubebank:1.0`
```
 ✓ Image stored for indexing
    ✓ Indexed 317 packages

    i Base image was auto-detected. To get more accurate results, build images with max-mode provenance attestations.
      Review docs.docker.com ↗ for more information.

 Target             │  kubebank:1.0  │    0C     4H   888M    33L  
   digest           │  8308e2611694  │                             
 Base image         │  ubuntu:24.04  │    0C     0H     8M    11L  
 Updated base image │  ubuntu:26.04  │    0C     0H     0M     0L  
                    │                │                  -8    -11  

What's next:
    View vulnerabilities → docker scout cves kubebank:1.0
    View base image update recommendations → docker scout recommendations kubebank:1.0
    Include policy results in your quickview by supplying an organization → docker scout quickview kubebank:1.0 --org <organization>

```
Escolhemos colocar a imagem do chainguard python para reduzir os CVEs, arquivo:
```

```
Automação do scout com: [rundeck](https://www.rundeck.com) para automatizar os testes
