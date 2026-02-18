# Day 13 - Imagens de containers e Wolfi

Para manter a integridade do cluster k8s é preciso pensar na segurança e na confiabilidade das imagens, testando as vulnerabilidades.

- Containerizando uma imagem:
precisamos montar uma imagem de exemplo, como o giropops-senhas da badtux.\
clona o repositório: `git clone https://github.com/badtuxx/giropops-senhas.git `  \
verifique se tem o pip instalado e se o python está atualizado.\
inicializa pelo venv do python:  `python3 -m venv ./ `\
ativa o venv: `source bin/activate ` \
instala dependências: `pip install -r requirements.txt` \
roda o flask no venv: `flask run --host=0.0.0.0` \
cria a variavel redishost `export REDIS_HOST=localhost `\

Agora a aplicação está rodando local, precisamos rodar em um container.

criamos o arquivo Dockerfile \ 

criar o build do docker `docker image build -t giropops-senhas:1.0 .`

verificando a imagem `docker image ls`\
```
> docker image ls                                                                                                                kubernetes-admin@kubernetes
REPOSITORY               TAG             IMAGE ID       CREATED          SIZE
giropops-senhas          1.0             9bc7f6808cdc   13 seconds ago   1.14GB
```
Roda a imagem para validar: `docker run -d --name giropops-senhas -e REDIS_HOST=192.168.0.106 -p 5000:5000 giropops-senhas:1.0`\
verificca com `docker ps`\
verifica logs com `docker container logs giropops-senhas`\
temos o erro do redis, pois não inserimos a localização \
para rodar o redis em um docker `docker run -d --name redis -p 6379:6379 redis` \

aqui temos a aplicação rodando no docker run.

```
> docker image ls                                                                                                                kubernetes-admin@kubernetes
REPOSITORY               TAG             IMAGE ID       CREATED          SIZE
giropops-senhas          1.0             9bc7f6808cdc   17 minutes ago   1.14GB
redis                    latest          6a157c60baea   7 days ago       140MB
```
nossa imagem está bem grande e no momento do build, vai comer muitos dados. O python tem a opção 'slim', ficando como:
```
> docker image ls                                                                                                                kubernetes-admin@kubernetes
REPOSITORY               TAG             IMAGE ID       CREATED          SIZE
giropops-senhas          2.0             f94804cadfce   58 seconds ago   161MB
giropops-senhas          1.0             9bc7f6808cdc   19 minutes ago   1.14GB
redis                    latest          6a157c60baea   7 days ago       140MB
```
Agora vamos verificar as vulnerabilidades e as camadas: `docker history giropops-senhas:1.0` :
```
> docker history giropops-senhas:1.0                                                                                             kubernetes-admin@kubernetes
IMAGE          CREATED          CREATED BY                                      SIZE      COMMENT
9bc7f6808cdc   21 minutes ago   CMD ["flask" "run" "--host=0.0.0.0"]            0B        buildkit.dockerfile.v0
<missing>      21 minutes ago   EXPOSE map[5000/tcp:{}]                         0B        buildkit.dockerfile.v0
<missing>      21 minutes ago   RUN /bin/sh -c pip install --no-cache-dir -r…   18.4MB    buildkit.dockerfile.v0
<missing>      21 minutes ago   COPY . . # buildkit                             18MB      buildkit.dockerfile.v0
<missing>      21 minutes ago   WORKDIR /app                                    0B        buildkit.dockerfile.v0
<missing>      13 days ago      CMD ["python3"]                                 0B        buildkit.dockerfile.v0
<missing>      13 days ago      RUN /bin/sh -c set -eux;  for src in idle3 p…   36B       buildkit.dockerfile.v0
<missing>      13 days ago      RUN /bin/sh -c set -eux;   wget -O python.ta…   63.9MB    buildkit.dockerfile.v0
<missing>      13 days ago      ENV PYTHON_SHA256=8d3ed8ec5c88c1c95f5e558612…   0B        buildkit.dockerfile.v0
<missing>      13 days ago      ENV PYTHON_VERSION=3.11.14                      0B        buildkit.dockerfile.v0
<missing>      13 days ago      ENV GPG_KEY=A035C8C19219BA821ECEA86B64E628F8…   0B        buildkit.dockerfile.v0
<missing>      13 days ago      RUN /bin/sh -c set -eux;  apt-get update;  a…   17.9MB    buildkit.dockerfile.v0
<missing>      13 days ago      ENV LANG=C.UTF-8                                0B        buildkit.dockerfile.v0
<missing>      13 days ago      ENV PATH=/usr/local/bin:/usr/local/sbin:/usr…   0B        buildkit.dockerfile.v0
<missing>      2 weeks ago      RUN /bin/sh -c set -ex;  apt-get update;  ap…   656MB     buildkit.dockerfile.v0
<missing>      2 weeks ago      RUN /bin/sh -c set -eux;  apt-get update;  a…   185MB     buildkit.dockerfile.v0
<missing>      2 weeks ago      RUN /bin/sh -c set -eux;  apt-get update;  a…   60.2MB    buildkit.dockerfile.v0
<missing>      2 weeks ago      # debian.sh --arch 'amd64' out/ 'trixie' '@1…   120MB     debuerreotype 0.17
```
`docker history giropops-senhas:2.0` :
```
> docker history giropops-senhas:2.0                                                                                             kubernetes-admin@kubernetes
IMAGE          CREATED         CREATED BY                                      SIZE      COMMENT
f94804cadfce   2 minutes ago   CMD ["flask" "run" "--host=0.0.0.0"]            0B        buildkit.dockerfile.v0
<missing>      2 minutes ago   EXPOSE map[5000/tcp:{}]                         0B        buildkit.dockerfile.v0
<missing>      2 minutes ago   RUN /bin/sh -c pip install --no-cache-dir -r…   18.4MB    buildkit.dockerfile.v0
<missing>      2 minutes ago   COPY . . # buildkit                             18MB      buildkit.dockerfile.v0
<missing>      2 minutes ago   WORKDIR /app                                    0B        buildkit.dockerfile.v0
<missing>      13 days ago     CMD ["python3"]                                 0B        buildkit.dockerfile.v0
<missing>      13 days ago     RUN /bin/sh -c set -eux;  for src in idle3 p…   36B       buildkit.dockerfile.v0
<missing>      13 days ago     RUN /bin/sh -c set -eux;   savedAptMark="$(a…   42MB      buildkit.dockerfile.v0
<missing>      13 days ago     ENV PYTHON_SHA256=8d3ed8ec5c88c1c95f5e558612…   0B        buildkit.dockerfile.v0
<missing>      13 days ago     ENV PYTHON_VERSION=3.11.14                      0B        buildkit.dockerfile.v0
<missing>      13 days ago     ENV GPG_KEY=A035C8C19219BA821ECEA86B64E628F8…   0B        buildkit.dockerfile.v0
<missing>      13 days ago     RUN /bin/sh -c set -eux;  apt-get update;  a…   3.81MB    buildkit.dockerfile.v0
<missing>      13 days ago     ENV LANG=C.UTF-8                                0B        buildkit.dockerfile.v0
<missing>      13 days ago     ENV PATH=/usr/local/bin:/usr/local/sbin:/usr…   0B        buildkit.dockerfile.v0
<missing>      2 weeks ago     # debian.sh --arch 'amd64' out/ 'trixie' '@1…   78.6MB    debuerreotype 0.17
```

- Distroless : é uma imagem de container que só tem uma camada. sem imagem base. \

utilizando o python alpine: 
```
Dockerfile
FROM python:3.11.4-alpine3.18

WORKDIR /app
COPY . .

RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 5000

CMD ["flask", "run", "--host=0.0.0.0"]


> docker image ls                                                                                                                kubernetes-admin@kubernetes
REPOSITORY               TAG             IMAGE ID       CREATED          SIZE
giropops-senhas          3.0             3f0aef7aaf1d   8 seconds ago    88.2MB
giropops-senhas          2.0             f94804cadfce   12 minutes ago   161MB
giropops-senhas          1.0             9bc7f6808cdc   31 minutes ago   1.14GB
redis                    latest          6a157c60baea   7 days ago       140MB

> docker history giropops-senhas:3.0                                                                                             kubernetes-admin@kubernetes
IMAGE          CREATED          CREATED BY                                      SIZE      COMMENT
3f0aef7aaf1d   55 seconds ago   CMD ["flask" "run" "--host=0.0.0.0"]            0B        buildkit.dockerfile.v0
<missing>      55 seconds ago   EXPOSE map[5000/tcp:{}]                         0B        buildkit.dockerfile.v0
<missing>      55 seconds ago   RUN /bin/sh -c pip install --no-cache-dir -r…   18.3MB    buildkit.dockerfile.v0
<missing>      57 seconds ago   COPY . . # buildkit                             18MB      buildkit.dockerfile.v0
<missing>      58 seconds ago   WORKDIR /app                                    0B        buildkit.dockerfile.v0
<missing>      2 years ago      CMD ["python3"]                                 0B        buildkit.dockerfile.v0
<missing>      2 years ago      RUN /bin/sh -c set -eux;   wget -O get-pip.p…   11.1MB    buildkit.dockerfile.v0
<missing>      2 years ago      ENV PYTHON_GET_PIP_SHA256=45a2bb8bf2bb5eff16…   0B        buildkit.dockerfile.v0
<missing>      2 years ago      ENV PYTHON_GET_PIP_URL=https://github.com/py…   0B        buildkit.dockerfile.v0
<missing>      2 years ago      ENV PYTHON_SETUPTOOLS_VERSION=65.5.1            0B        buildkit.dockerfile.v0
<missing>      2 years ago      ENV PYTHON_PIP_VERSION=23.1.2                   0B        buildkit.dockerfile.v0
<missing>      2 years ago      RUN /bin/sh -c set -eux;  for src in idle3 p…   32B       buildkit.dockerfile.v0
<missing>      2 years ago      RUN /bin/sh -c set -eux;   apk add --no-cach…   32MB      buildkit.dockerfile.v0
<missing>      2 years ago      ENV PYTHON_VERSION=3.11.4                       0B        buildkit.dockerfile.v0
<missing>      2 years ago      ENV GPG_KEY=A035C8C19219BA821ECEA86B64E628F8…   0B        buildkit.dockerfile.v0
<missing>      2 years ago      RUN /bin/sh -c set -eux;  apk add --no-cache…   1.64MB    buildkit.dockerfile.v0
<missing>      2 years ago      ENV LANG=C.UTF-8                                0B        buildkit.dockerfile.v0
<missing>      2 years ago      ENV PATH=/usr/local/bin:/usr/local/sbin:/usr…   0B        buildkit.dockerfile.v0
<missing>      2 years ago      /bin/sh -c #(nop)  CMD ["/bin/sh"]              0B        
<missing>      2 years ago      /bin/sh -c #(nop) ADD file:32ff5e7a78b890996…   7.34MB   
```
agora vamos utilizar a chainguard.dev buscando por python: [https://images.chainguard.dev/directory/image/python/versions](https://images.chainguard.dev/directory/image/python/versions)
utilizando a adaptação para instalar os requirements: 
```
FROM cgr.dev/chainguard/python:latest-dev as dev

WORKDIR /app

RUN python -m venv venv
ENV PATH="/app/venv/bin":$PATH
COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt

FROM cgr.dev/chainguard/python:latest
WORKDIR /app
COPY . . 
COPY --from=dev /app/venv /app/venv
ENV PATH="/app/venv/bin:$PATH"


ENTRYPOINT ["flask", "run", "--host=0.0.0.0"]

> docker image ls                                                                                                                kubernetes-admin@kubernetes
REPOSITORY               TAG             IMAGE ID       CREATED          SIZE
giropops-senhas          4.1             15f177ce3847   59 seconds ago   83MB

> docker history giropops-senhas:4.1                                                                                             kubernetes-admin@kubernetes
IMAGE          CREATED              CREATED BY                                      SIZE      COMMENT
15f177ce3847   About a minute ago   ENTRYPOINT ["flask" "run" "--host=0.0.0.0"]     0B        buildkit.dockerfile.v0
<missing>      About a minute ago   ENV PATH=/app/venv/bin:/usr/local/sbin:/usr/…   0B        buildkit.dockerfile.v0
<missing>      About a minute ago   COPY /app/venv /app/venv # buildkit             19.1MB    buildkit.dockerfile.v0
<missing>      About a minute ago   COPY static ./static # buildkit                 101kB     buildkit.dockerfile.v0
<missing>      About a minute ago   COPY templates ./templates # buildkit           5.78kB    buildkit.dockerfile.v0
<missing>      About a minute ago   COPY app.py . # buildkit                        2.52kB    buildkit.dockerfile.v0
<missing>      14 minutes ago       WORKDIR /app                                    0B        buildkit.dockerfile.v0
<missing>      24 hours ago         apko                                            123kB     python by Chainguard
<missing>      24 hours ago         apko                                            2.78MB    python by Chainguard
<missing>      24 hours ago         apko                                            1.07MB    python by Chainguard
<missing>      24 hours ago         apko                                            1.4MB     python by Chainguard
<missing>      24 hours ago         apko                                            1.65MB    python by Chainguard
<missing>      24 hours ago         apko                                            1.64MB    python by Chainguard
<missing>      24 hours ago         apko                                            1.81MB    python by Chainguard
<missing>      24 hours ago         apko                                            3.48MB    python by Chainguard
<missing>      24 hours ago         apko                                            6.93MB    python by Chainguard
<missing>      24 hours ago         apko                                            7.18MB    python by Chainguard
<missing>      24 hours ago         apko                                            35.7MB    python by Chainguard
```
temos uma imagem enxuta e com menos etapas de criação.

## Ferramentas para scanear images e verificar vulnerabilidades.

- [{https://trivy.dev}](https://trivy.dev) \ 
pagina de instalação: [https://trivy.dev/docs/latest/getting-started/installation](https://trivy.dev/docs/latest/getting-started/installation) \
rodando o trivy:
```
> trivy image giropops-senhas:1.0
vulnerabilidades do python nem chega no fim
Python (python-pkg)

Total: 7 (UNKNOWN: 0, LOW: 2, MEDIUM: 2, HIGH: 3, CRITICAL: 0)

> trivy image giropops-senhas:4.1                                                                                                kubernetes-admin@kubernetes
2026-02-18T15:12:22-03:00       INFO    [vuln] Vulnerability scanning is enabled
2026-02-18T15:12:22-03:00       INFO    [secret] Secret scanning is enabled
2026-02-18T15:12:22-03:00       INFO    [secret] If your scanning is slow, please try '--scanners vuln' to disable secret scanning
2026-02-18T15:12:22-03:00       INFO    [secret] Please see https://trivy.dev/docs/v0.69/guide/scanner/secret#recommendation for faster secret detection
2026-02-18T15:12:24-03:00       INFO    [python] Licenses acquired from one or more METADATA files may be subject to additional terms. Use `--debug` flag to see all affected packages.
2026-02-18T15:12:24-03:00       INFO    Detected OS     family="wolfi" version="20230201"
2026-02-18T15:12:24-03:00       INFO    [wolfi] Detecting vulnerabilities...    pkg_num=25
2026-02-18T15:12:24-03:00       INFO    Number of language-specific files       num=1
2026-02-18T15:12:24-03:00       INFO    [python-pkg] Detecting vulnerabilities...

Report Summary

┌──────────────────────────────────────────────────────────────────────────────────┬────────────┬─────────────────┬─────────┐
│                                      Target                                      │    Type    │ Vulnerabilities │ Secrets │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ giropops-senhas:4.1 (wolfi 20230201)                                             │   wolfi    │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ app/venv/lib/python3.14/site-packages/blinker-1.9.0.dist-info/METADATA           │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ app/venv/lib/python3.14/site-packages/click-8.3.1.dist-info/METADATA             │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ app/venv/lib/python3.14/site-packages/flask-3.0.3.dist-info/METADATA             │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ app/venv/lib/python3.14/site-packages/itsdangerous-2.2.0.dist-info/METADATA      │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ app/venv/lib/python3.14/site-packages/jinja2-3.1.6.dist-info/METADATA            │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ app/venv/lib/python3.14/site-packages/markupsafe-3.0.3.dist-info/METADATA        │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ app/venv/lib/python3.14/site-packages/pip-26.0.1.dist-info/METADATA              │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ app/venv/lib/python3.14/site-packages/prometheus_client-0.16.0.dist-info/METADA- │ python-pkg │        0        │    -    │
│ TA                                                                               │            │                 │         │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ app/venv/lib/python3.14/site-packages/redis-4.5.4.dist-info/METADATA             │ python-pkg │        0        │    -    │
├──────────────────────────────────────────────────────────────────────────────────┼────────────┼─────────────────┼─────────┤
│ app/venv/lib/python3.14/site-packages/werkzeug-3.1.5.dist-info/METADATA          │ python-pkg │        0        │    -    │
└──────────────────────────────────────────────────────────────────────────────────┴────────────┴─────────────────┴─────────┘
Legend:
- '-': Not scanned
- '0': Clean (no security findings detected)
```
* Imagem limpa

## Utilizando docker scout

```
> docker scout cves giropops-senhas:1.0

166 vulnerabilities found in 45 packages
  CRITICAL     0   
  HIGH         5   
  MEDIUM       10  
  LOW          149 
  UNSPECIFIED  2 

> docker scout cves giropops-senhas:4.1                                                                                          kubernetes-admin@kubernetes
    ✓ Image stored for indexing
    ✓ Indexed 63 packages
    ✓ No vulnerable package detected


## Overview

                   │       Analyzed Image        
───────────────────┼─────────────────────────────
 Target            │  giropops-senhas:4.1        
   digest          │  15f177ce3847               
   platform        │ linux/amd64                 
   vulnerabilities │    0C     0H     0M     0L  
   size            │ 35 MB                       
   packages        │ 63                          


## Packages and Vulnerabilities

  No vulnerable packages detected

```

## Assinando imagens

Para garantir a segurança da sua imagem, alem de verificar as vulnerabilidades, precisamos assinar as imagens, para isso utilizamos cosign.

- Utilizando o cosign [https://github.com/sigstore/cosign](https://github.com/sigstore/cosign)

gerando chaves: 
```
> cosign generate-key-pair  
> docker image build -t carlosclaro/goropops-senhas:1.0 .
> cosign sign -key cosign.key carlosclaro/goropops-senhas:1.0
> cosign verify --key cosign.pub carlosclaro/goropops-senhas:1.0

Verification for index.docker.io/carlosclaro/goropops-senhas:1.0 --
The following checks were performed on each of these signatures:
  - The cosign claims were validated
  - Existence of the claims in the transparency log was verified offline
  - The signatures were verified against the specified public key

[{"critical":{"identity":{"docker-reference":"index.docker.io/carlosclaro/goropops-senhas:1.0"},"image":{"docker-manifest-digest":"sha256:cad261588dad86d06c85a9203caed987adcf5b27b38e0320994356849f3d7101"},"type":"https://sigstore.dev/cosign/sign/v1"},"optional":{}},{"critical":{"identity":{"docker-reference":"index.docker.io/carlosclaro/goropops-senhas:1.0"},"image":{"docker-manifest-digest":"sha256:cad261588dad86d06c85a9203caed987adcf5b27b38e0320994356849f3d7101"},"type":"https://sigstore.dev/cosign/sign/v1"},"optional":{}},{"critical":{"identity":{"docker-reference":"index.docker.io/carlosclaro/goropops-senhas:1.0"},"image":{"docker-manifest-digest":"sha256:cad261588dad86d06c85a9203caed987adcf5b27b38e0320994356849f3d7101"},"type":"https://sigstore.dev/cosign/sign/v1"},"optional":{}}]
```



