Objetivo

Quero criar uma pipeline que vai fazer deploy de um cluster de kubernetes no azure O AKS

Estratégia de Ambientes e Resource Groups

cada ambiente vai criar em um resource group separado
os resource group vamos usar comandos do az cli para criar

gh-devops-dev

gh-devops-hml

gh-devops-prd

Estado Remoto (Terraform State)

os arquivos de estados serão guardados em um storage account em outro RG esses recursos serão criados com az cli

resource group de estado remoto: gh-terraform

storage account: ghdevopsautomatf

container: tfstate

cada ambiente vai ter sua própria chave no backend do storage account utilizando o mesmo container, mas com keys diferentes para isolar os estados

exemplo de keys no backend:

aks/dev.tfstate

aks/hml.tfstate

aks/prod.tfstate

isso garante que cada ambiente tenha seu estado separado sem sobrescrever as configurações conforme boas práticas oficiais da Microsoft para backend no Azure

Provisionamento com Terraform

vou provisionar um cluster na azure AKS usando o terraform
vou usar o tvars
e quero usar boas praticas de branch
vamos separar por etapas
o terraform vai provisionar um aks usando as boas práticas com os arquivos tf separados

Estrutura de Pastas do Terraform
dev/
  dev.tfvars
hml/
  hml.tfvars
prod/
  prod.tfvars

main.tf
outputs.tf
variables.tf
ingress.tf
helm.tf

Instalações via Helm (pelo Terraform)

vou instalar o ingress usando o helm no terraform
entao ele tb vai ter de forma separada o seu arquivo ingress.tf
o argo rollouts vou instalar tambem via helm usando helm.tf tambem

Fluxo de Branches e Deploy

quando o usuario criar um branch feature/ALGUMA_COISA ele vai fazer as validações de plan do terraform

em seguida quando tudo tiver ok vai ser aberto uma PR feature/alguma_coisa -> develop
nesse momento vai ser realizado um deploy no ambiente de desenvolvimento provisionando o cluster AKS com as configurações usando o dev.tfvars no resource group gh-devops-dev

quando terminar o deploy vai abrir uma PR automática de develop -> homologcao
nesse momento vai ser realizado o deploy usando as configurações de hml.tfvars no resource group gh-devops-hml

quando o deploy for finalizado vai ser aberta uma PR automática para homologacao -> main
e vai ser realizado o deploy usando as configurações prod.tfvars no ambiente gh-devops-prd