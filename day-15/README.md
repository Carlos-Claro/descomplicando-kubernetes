# Day 15 - Kyverno e policies

- [Documentação Kyverno](https://kyverno.io/docs/introduction)

Ferramenta de gerenciamento de policies, buscando mais segurança.\
Existe um padrão que é o OPA , porem utiliza uma nova linguagem, por isso vamos utilizar Kyverno.\
Podemos utilizar dois tipos de execução e utilizar as policies:
- enforce: impõem a regra e não deixa passar
- audit: avisa que está quebrando as regras, porém deixa continuar a funcionalidade.


- Validação de recusrsos: Vai garantir que regras como uso de memória ou cpu, sejam aplicadas obrigatóriamente, validando os recursos. \
- Mutação de recusrsos: Consegue modificar os recursos, em caso de labels, vai forçar para que fique no padrão \
- Geração de recursos: Pode criar itens que estão descritos nas regras \

Vamos utilizar Helm para instalação, o Kyverno é um operator que vai instalar CustomResourceDefinition.

## Instalação Kyverno via Helm:

```
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update
helm install kyverno kyverno/kyverno -n kyverno --create-namespace
```
[Saiba mais sobre as policies do kyverno](https://kyverno.io/policies)

## Níveis de Policies:
- ClusterPolicies - regras que se aplicam ao cluster todo
- Policies - regras que se aplicam apenas para o namespace específico


## Tipos de Policies:
- Mutate: altera o comportamento do recurso
- Validate: valida e libera a ação sugerida.


- Política de Limites de Recursos: Garantir que todos os containers em um Pod tenham limites de CPU e memória definidos. Isso pode ser importante para evitar o uso excessivo de recursos em um cluster compartilhado. [require-resources-limits.yaml](./require-resources-limits.yaml)
- Label ao Namespace: A política add-label-namespace é projetada para automatizar a adição de um label específico a todos os Namespaces em um cluster Kubernetes. Esta abordagem é essencial para a organização, monitoramento e controle de acesso em ambientes complexos.[add-label-namespace.yaml](./add-label-namespace.yaml)
- Gerar ConfigMap para Namespace: A política generate-configmap-for-namespace é uma estratégia prática no gerenciamento de Kubernetes para automatizar a criação de ConfigMaps em Namespaces. Esta política simplifica a configuração e a gestão de múltiplos ambientes dentro de um cluster.[generate-cm-adding-limits.yaml](./generate-cm-adding-limits.yaml)
- Proibir Usuário Root: A política disallow-root-user é uma regra de segurança crítica no gerenciamento de clusters Kubernetes. Ela proíbe a execução de containers como usuário root dentro de Pods. Este controle ajuda a prevenir possíveis vulnerabilidades de segurança e a reforçar as melhores práticas no ambiente de contêineres.[disallow-rootuser.yaml](./disallow-rootuser.yaml)
- Permitir Apenas Repositórios Confiáveis
A política ensure-images-from-trusted-repo é essencial para a segurança dos clusters Kubernetes, garantindo que todos os Pods utilizem imagens provenientes apenas de repositórios confiáveis. Esta política ajuda a prevenir a execução de imagens não verificadas ou potencialmente mal-intencionadas.[trusted-registry.yaml](./trusted-registry.yaml)
- Usando o Exclude: A política require-resources-limits é uma abordagem proativa para gerenciar a utilização de recursos em um cluster Kubernetes. Ela garante que todos os Pods tenham limites de recursos definidos, como CPU e memória, mas com uma exceção específica para um namespace.

