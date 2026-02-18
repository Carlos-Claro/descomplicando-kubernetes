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
```
