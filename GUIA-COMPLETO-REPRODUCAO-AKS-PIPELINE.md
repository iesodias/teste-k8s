# Guia Completo: Reprodução do Pipeline AKS CI/CD

## Índice
1. [Pré-requisitos](#1-pré-requisitos)
2. [Clonagem e Preparação do Ambiente](#2-clonagem-e-preparação-do-ambiente)
3. [Criação do Novo Repositório GitHub](#3-criação-do-novo-repositório-github)
4. [Configuração da Infraestrutura Azure](#4-configuração-da-infraestrutura-azure)
5. [Configuração do Service Principal](#5-configuração-do-service-principal)
6. [Configuração dos GitHub Secrets](#6-configuração-dos-github-secrets)
7. [Teste dos Workflows](#7-teste-dos-workflows)
8. [Validação Completa](#8-validação-completa)
9. [Troubleshooting](#9-troubleshooting)
10. [Cleanup e Manutenção](#10-cleanup-e-manutenção)

---

## 1. Pré-requisitos

### 1.1 Ferramentas Necessárias

Antes de começar, certifique-se de ter as seguintes ferramentas instaladas:

#### Azure CLI
```bash
# Instalar Azure CLI (macOS)
brew install azure-cli

# Instalar Azure CLI (Ubuntu/Debian)
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Instalar Azure CLI (Windows)
# Baixar de: https://aka.ms/installazurecliwindows

# Verificar instalação
az --version
```

#### Terraform
```bash
# Instalar Terraform (macOS)
brew install terraform

# Instalar Terraform (Ubuntu/Debian)
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

# Verificar instalação
terraform --version
```

#### Git
```bash
# Git já vem instalado na maioria dos sistemas, mas verificar versão
git --version

# Se não estiver instalado:
# macOS: git vem com Xcode Command Line Tools
# Ubuntu/Debian: sudo apt install git
# Windows: https://git-scm.com/download/win
```

#### kubectl
```bash
# Instalar kubectl (macOS)
brew install kubectl

# Instalar kubectl (Ubuntu/Debian)
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Verificar instalação
kubectl version --client
```

### 1.2 Contas e Permissões

#### Azure Subscription
- Conta Azure ativa com permissões de Owner ou Contributor
- Subscription ID anotado
- Tenant ID anotado

#### GitHub Account
- Conta GitHub com possibilidade de criar repositórios privados/públicos

** CHECKPOINT 1**: Todas as ferramentas instaladas e funcionando

---

## 2. Clonagem e Preparação do Ambiente

### 2.1 Clonar o Repositório de Exemplo

```bash
# Navegar para o diretório home
cd ~

# Clonar o repositório de exemplo
git clone https://github.com/SEU_USUARIO/udemy-k8s-gh.git aks-pipeline-exemplo

# Entrar no diretório
cd aks-pipeline-exemplo

# Verificar estrutura
ls -la
```

### 2.2 Examinar a Estrutura do Projeto

```bash
# Listar todos os arquivos importantes
find . -type f \( -name "*.yml" -o -name "*.yaml" -o -name "*.tf" -o -name "*.tfvars" -o -name "*.sh" -o -name "*.md" \) | sort

# Estrutura esperada:
# .github/workflows/00-feature.yml
# .github/workflows/01-develop.yml
# .github/workflows/02-homologacao.yml
# .github/workflows/03-main.yml
# .github/workflows/destroy-environment.yml
# terraform/backend.tf
# terraform/helm.tf
# terraform/ingress.tf
# terraform/main.tf
# terraform/outputs.tf
# terraform/providers.tf
# terraform/variables.tf
# terraform/dev/dev.tfvars
# terraform/hml/hml.tfvars
# terraform/prod/prod.tfvars
# scripts/cleanup-all-infrastructure.sh
# scripts/setup-azure-infrastructure.sh
# scripts/setup-service-principal.sh
# CLAUDE.md
# README.md
```

** CHECKPOINT 2**: Repositório clonado e estrutura verificada

---

## 3. Criação do Novo Repositório GitHub

### 3.1 Criar Novo Repositório (Interface Web)

1. **Acessar GitHub**:
   - Vá para https://github.com
   - Faça login em sua conta

2. **Criar Repositório**:
   - Clique no botão **"+"** no canto superior direito
   - Selecione **"New repository"**
   - **Repository name**: `meu-aks-pipeline` (ou nome de sua escolha)
   - **Description**: `Pipeline AKS CI/CD com Terraform`
   - **Private** ou **Public** (sua escolha)
   -  Marque **"Add a README file"**
   -  Marque **"Add .gitignore"** e selecione **"Terraform"**
   - Clique em **"Create repository"**

3. **Clonar Localmente**:
```bash
# Navegar para o diretório home
cd ~

# Clonar seu novo repositório (substitua SEU_USUARIO pelo seu username)
git clone https://github.com/SEU_USUARIO/meu-aks-pipeline.git

# Navegar para o repositório
cd meu-aks-pipeline
```

### 3.2 Copiar Arquivos Essenciais

```bash
# Criar estrutura de diretórios
mkdir -p .github/workflows
mkdir -p terraform/{dev,hml,prod}
mkdir -p scripts

# Copiar workflows do GitHub Actions
cp ~/aks-pipeline-exemplo/.github/workflows/*.yml .github/workflows/

# Copiar arquivos Terraform
cp ~/aks-pipeline-exemplo/terraform/*.tf terraform/
cp ~/aks-pipeline-exemplo/terraform/dev/dev.tfvars terraform/dev/
cp ~/aks-pipeline-exemplo/terraform/hml/hml.tfvars terraform/hml/
cp ~/aks-pipeline-exemplo/terraform/prod/prod.tfvars terraform/prod/

# Copiar scripts
cp ~/aks-pipeline-exemplo/scripts/*.sh scripts/

# Copiar documentação
cp ~/aks-pipeline-exemplo/CLAUDE.md .
cp ~/aks-pipeline-exemplo/README.md .
cp ~/aks-pipeline-exemplo/.gitignore .

# Tornar scripts executáveis
chmod +x scripts/*.sh
```

### 3.3 Personalizar Configurações

#### Editar arquivos tfvars para seu ambiente:

```bash
# Editar configuração de desenvolvimento
cat > terraform/dev/dev.tfvars << 'EOF'
# Development Environment Configuration
environment         = "dev"
location            = "brazilsouth"
resource_group_name = "MEU-NOME-devops-dev"

# AKS Cluster Configuration
aks_cluster_name   = "aks-MEU-NOME-dev"
aks_dns_prefix     = "aks-MEU-NOME-dev"
kubernetes_version = "1.31.11"

# Helm Charts Configuration
nginx_ingress_enabled = true
argo_rollouts_enabled = true

# Tags
tags = {
  Project     = "AKS-CI-CD"
  Environment = "development"
  ManagedBy   = "Terraform"
  Owner       = "SEU-NOME"
  CostCenter  = "Development"
  Purpose     = "Development-Testing"
}
EOF

# Editar configuração de homologação
cat > terraform/hml/hml.tfvars << 'EOF'
# Homologation Environment Configuration
environment         = "hml"
location            = "brazilsouth"
resource_group_name = "MEU-NOME-devops-hml"

# AKS Cluster Configuration
aks_cluster_name   = "aks-MEU-NOME-hml"
aks_dns_prefix     = "aks-MEU-NOME-hml"
kubernetes_version = "1.31.11"

# Helm Charts Configuration
nginx_ingress_enabled = true
argo_rollouts_enabled = true

# Tags
tags = {
  Project     = "AKS-CI-CD"
  Environment = "homologation"
  ManagedBy   = "Terraform"
  Owner       = "SEU-NOME"
  CostCenter  = "Development"
  Purpose     = "Homologation-Testing"
}
EOF

# Editar configuração de produção
cat > terraform/prod/prod.tfvars << 'EOF'
# Production Environment Configuration
environment         = "prod"
location            = "brazilsouth"
resource_group_name = "MEU-NOME-devops-prd"

# AKS Cluster Configuration
aks_cluster_name   = "aks-MEU-NOME-prd"
aks_dns_prefix     = "aks-MEU-NOME-prd"
kubernetes_version = "1.31.11"

# Helm Charts Configuration
nginx_ingress_enabled = true
argo_rollouts_enabled = true

# Tags
tags = {
  Project     = "AKS-CI-CD"
  Environment = "production"
  ManagedBy   = "Terraform"
  Owner       = "SEU-NOME"
  CostCenter  = "Production"
  Purpose     = "Production-Workloads"
}
EOF
```

### 3.4 Personalizar Scripts

```bash
# Editar o script de setup da infraestrutura Azure
sed -i 's/TERRAFORM_RG="gh-terraform"/TERRAFORM_RG="MEU-NOME-terraform"/' scripts/setup-azure-infrastructure.sh
sed -i 's/STORAGE_ACCOUNT="ghdevopsautomatf"/STORAGE_ACCOUNT="MEU-NOME$(date +%s)"/' scripts/setup-azure-infrastructure.sh
sed -i 's/DEV_RG="gh-devops-dev"/DEV_RG="MEU-NOME-devops-dev"/' scripts/setup-azure-infrastructure.sh
sed -i 's/HML_RG="gh-devops-hml"/HML_RG="MEU-NOME-devops-hml"/' scripts/setup-azure-infrastructure.sh
sed -i 's/PRD_RG="gh-devops-prd"/PRD_RG="MEU-NOME-devops-prd"/' scripts/setup-azure-infrastructure.sh
```

### 3.5 Commit Inicial

```bash
# Adicionar todos os arquivos
git add .

# Commit inicial
git commit -m "Initial commit: AKS CI/CD Pipeline setup

- Added GitHub Actions workflows for multi-environment deployment
- Added Terraform infrastructure code for AKS clusters
- Added Azure setup scripts
- Configured dev/hml/prod environments"

# Push para o repositório
git push origin main
```

### 3.6 Criar Branches Necessárias

A pipeline funciona com 4 branches específicas. Vamos criá-las:

```bash
# Certificar que estamos na main
git checkout main

# Criar branch develop (para ambiente DEV)
git checkout -b develop
git push origin develop

# Criar branch homologacao (para ambiente HML)
git checkout -b homologacao
git push origin homologacao

# Voltar para main
git checkout main

# Verificar branches criadas
git branch -a
```

**Branches esperadas:**
```
* main                    # Produção (PROD)
  develop                 # Desenvolvimento (DEV)
  homologacao            # Homologação (HML)
  remotes/origin/develop
  remotes/origin/homologacao
  remotes/origin/main
```

### 3.7 Configurar Branch Protection (Opcional)

**Via GitHub Web:**
1. Vá para **Settings** > **Branches**
2. **Add rule** para `main`:
   - Require pull request reviews before merging
   - Require status checks to pass before merging
3. **Add rule** para `develop`:
   - Require status checks to pass before merging

** CHECKPOINT 3**: Novo repositório criado e configurado

---

## 4. Configuração da Infraestrutura Azure

### 4.1 Login no Azure

```bash
# Fazer login no Azure
az login

# Listar subscriptions disponíveis
az account list --output table

# Definir a subscription padrão (substitua pelo seu ID)
az account set --subscription "SEU-SUBSCRIPTION-ID"

# Verificar subscription ativa
az account show --output table
```

### 4.2 Executar Setup da Infraestrutura

```bash
# Navegar para o diretório do projeto
cd ~/meu-aks-pipeline

# Executar script de setup
./scripts/setup-azure-infrastructure.sh
```

**Saída esperada:**
```
 Setting up Azure infrastructure for AKS CI/CD Pipeline...
 Creating Terraform state Resource Group...
 Resource Group 'MEU-NOME-terraform' created successfully
 Creating Storage Account for Terraform state...
 Storage Account 'MEU-NOME1234567890' created successfully
 Creating container for Terraform state...
 Container 'tfstate' created successfully
 Creating environment Resource Groups...
 Resource Group 'MEU-NOME-devops-dev' created successfully
 Resource Group 'MEU-NOME-devops-hml' created successfully
 Resource Group 'MEU-NOME-devops-prd' created successfully

 Azure infrastructure setup completed!

 Backend configuration for Terraform:
--------------------------------------------
resource_group_name  = "MEU-NOME-terraform"
storage_account_name = "MEU-NOME1234567890"
container_name       = "tfstate"
key                  = "aks/{environment}.tfstate"

 Storage Account Key (for GitHub Secrets):
ARM_ACCESS_KEY=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

 Next steps:
1. Add ARM_ACCESS_KEY to GitHub repository secrets
2. Configure Azure Service Principal for GitHub Actions
3. Run terraform init with the backend configuration
```

### 4.3 Atualizar Backend Configuration

```bash
# Anotar o storage account name gerado e atualizar backend.tf
# Substituir STORAGE_ACCOUNT_NAME pelo nome gerado
cat > terraform/backend.tf << 'EOF'
terraform {
  backend "azurerm" {
    resource_group_name  = "MEU-NOME-terraform"
    storage_account_name = "STORAGE_ACCOUNT_NAME_GERADO"
    container_name       = "tfstate"
    key                  = "aks/${var.environment}.tfstate"
  }
}
EOF
```

** CHECKPOINT 4**: Infraestrutura Azure base criada

---

## 5. Configuração do Service Principal

### 5.1 Executar Script de Service Principal

```bash
# Executar script de criação do Service Principal
./scripts/setup-service-principal.sh
```

**Saída esperada:**
```
 Setting up Azure Service Principal for GitHub Actions...

 Current Azure context:
Subscription ID: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
Tenant ID: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx

 Creating Service Principal...
 Service Principal 'sp-github-actions-aks' created successfully

 Service Principal Details:
Client ID: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
Client Secret: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

  Assigning roles to Service Principal...
 Role 'Contributor' assigned to subscription scope
 Role 'User Access Administrator' assigned to subscription scope

 Service Principal setup completed!

 GitHub Secrets Configuration:
==================================================

Add these secrets to your GitHub repository:

ARM_CLIENT_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
ARM_CLIENT_SECRET=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
ARM_SUBSCRIPTION_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
ARM_TENANT_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx

AZURE_CREDENTIALS={
  "clientId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "clientSecret": "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  "subscriptionId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "tenantId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}
```

** CHECKPOINT 5**: Service Principal configurado

---

## 6. Configuração dos GitHub Secrets

### 6.1 Adicionar Secrets via GitHub CLI

```bash
# Navegar para o diretório do projeto
cd ~/meu-aks-pipeline

# APENAS 2 SECRETS NECESSÁRIOS!

# 1. AZURE_CREDENTIALS (JSON do Service Principal)
gh secret set AZURE_CREDENTIALS --body '{
  "clientId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "clientSecret": "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  "subscriptionId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "tenantId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}'

# 2. ARM_ACCESS_KEY (Storage Account para Terraform backend)
gh secret set ARM_ACCESS_KEY --body "STORAGE_ACCESS_KEY_GERADO"

# 3. TOKEN_GB será configurado na próxima seção
```

### 6.1.1 Criar Personal Access Token (TOKEN_GB)

**PASSO-A-PASSO DETALHADO:**

1. **Acessar configurações do GitHub:**
   - Vá para https://github.com
   - Clique no seu **avatar** (canto superior direito)
   - Clique em **"Settings"**

2. **Navegar para tokens:**
   - No menu lateral esquerdo, vá para **"Developer settings"**
   - Clique em **"Personal access tokens"**
   - Clique em **"Tokens (classic)"**

3. **Criar novo token:**
   - Clique em **"Generate new token"**
   - Selecione **"Generate new token (classic)"**

4. **Configurar o token:**
   - **Note**: `AKS Pipeline Auto PR Creation`
   - **Expiration**: `No expiration` (ou 1 ano)
   - **Scopes** - MARQUE OBRIGATORIAMENTE:
     - ✅ **repo** (Full control of private repositories)
       - ✅ repo:status
       - ✅ repo_deployment
       - ✅ public_repo
       - ✅ repo:invite
       - ✅ security_events
     - ✅ **workflow** (Update GitHub Action workflows)
     - ✅ **write:packages** (Upload packages to GitHub Package Registry)
     - ✅ **read:packages** (Download packages from GitHub Package Registry)

5. **Gerar e copiar:**
   - Clique em **"Generate token"**
   - **COPIE O TOKEN IMEDIATAMENTE** (só aparece uma vez)
   - Token formato: `ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`

6. **Adicionar ao repositório:**
   - Vá para seu repositório
   - **Settings** > **Secrets and variables** > **Actions**
   - Clique **"New repository secret"**
   - **Name**: `TOKEN_GB`
   - **Secret**: Cole o token copiado
   - Clique **"Add secret"**

```bash
# Agora configure via CLI se preferir
gh secret set TOKEN_GB --body "ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

### 6.2 Verificar Secrets Configurados (Interface Web)

**Via GitHub Web:**
1. Vá para seu repositório no GitHub
2. **Settings** > **Secrets and variables** > **Actions**
3. Verifique se todos os 3 secrets estão configurados:

**Secrets necessários:**
```
ARM_ACCESS_KEY          Updated 2024-01-XX
AZURE_CREDENTIALS      Updated 2024-01-XX
TOKEN_GB               Updated 2024-01-XX
```

**OTIMIZAÇÃO**: Apenas 3 secrets são necessários! A autenticação foi simplificada:
- **AZURE_CREDENTIALS**: Autentica Azure CLI e Terraform provider automaticamente
- **ARM_ACCESS_KEY**: Apenas para o backend Storage Account
- **TOKEN_GB**: Para criação automática de PRs

** CHECKPOINT 6**: GitHub Secrets configurados

---

## 7. Teste dos Workflows

### 7.1 Entendendo o Fluxo das Branches

**Fluxo completo da pipeline:**
```
feature/* → develop → homologacao → main
   ↓           ↓            ↓        ↓
 Validate    DEV         HML      PROD
```

**Workflow por branch:**
- **feature/**: Executa `00-feature.yml` (validação + cria PR para develop)
- **develop**: Executa `01-develop.yml` (deploy DEV + cria PR para homologacao)
- **homologacao**: Executa `02-homologacao.yml` (deploy HML + cria PR para main)
- **main**: Executa `03-main.yml` (deploy PROD + auto-merge)

### 7.2 Teste do Workflow de Feature

```bash
# Certificar que estamos na main
git checkout main

# Criar branch de feature
git checkout -b feature/teste-inicial

# Fazer uma pequena alteração
echo "# Teste do Pipeline AKS CI/CD" > teste-feature.md

# Commit e push
git add .
git commit -m "feat: initial pipeline test"
git push origin feature/teste-inicial
```

### 7.3 Verificar Execução do Workflow (Interface Web)

**Acompanhar via GitHub:**
1. Vá para seu repositório no GitHub
2. Clique na aba **"Actions"**
3. Você verá o workflow **"Feature Branch Validation and PR Creation"** em execução
4. Clique no workflow para ver os logs detalhados

### 7.4 Acompanhar Logs do Workflow

**Via GitHub Web:**
1. Na aba **Actions**, clique no workflow em execução
2. Clique em **"validate-feature"** para ver os logs
3. Expanda cada step para ver detalhes:
   - Terraform Format Check
   - Terraform Validation
   - Security and Quality Checks

### 7.5 Merge para Develop

Após validação bem-sucedida, o workflow automaticamente criará um **Pull Request** para develop. Para continuar:

**Via GitHub Web:**
1. Vá para **Pull requests**
2. Você verá um PR: **"Auto-promote: feature/teste-inicial to DEV"**
3. **Review** e **Merge** o Pull Request

**OU via linha de comando:**
```bash
# Trocar para develop
git checkout develop

# Fazer merge da feature
git merge feature/teste-inicial
git push origin develop
```

### 7.6 Verificar Deploy para DEV

**Acompanhar via GitHub Web:**
1. Vá para seu repositório no GitHub
2. Clique na aba **"Actions"**
3. Procure pelo workflow **"DEV Deploy and Promote to HML"**
4. Acompanhe os logs de execução em tempo real

** CHECKPOINT 7**: Workflows funcionando corretamente

---

## 8. Validação Completa

### 8.1 Verificar Cluster AKS Criado

```bash
# Listar clusters AKS
az aks list --output table

# Conectar ao cluster DEV
az aks get-credentials --resource-group MEU-NOME-devops-dev --name aks-MEU-NOME-dev --overwrite-existing

# Verificar nodes
kubectl get nodes

# Verificar pods do sistema
kubectl get pods --all-namespaces
```

### 8.2 Verificar NGINX Ingress

```bash
# Verificar instalação do NGINX Ingress
kubectl get pods -n nginx-ingress
kubectl get svc -n nginx-ingress

# Verificar IP externo (pode levar alguns minutos)
kubectl get svc nginx-ingress-nginx-ingress-controller -n nginx-ingress
```

### 8.3 Verificar Argo Rollouts

```bash
# Verificar instalação do Argo Rollouts
kubectl get pods -n argo-rollouts
kubectl get crd | grep rollouts
```

### 8.4 Teste Completo do Pipeline

```bash
# Criar feature branch para teste completo
git checkout -b feature/pipeline-completo

# Adicionar arquivo de teste
cat > test-app.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-app
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: test-app
  template:
    metadata:
      labels:
        app: test-app
    spec:
      containers:
      - name: test-app
        image: nginx:latest
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: test-app-service
  namespace: default
spec:
  selector:
    app: test-app
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
EOF

# Commit e push
git add .
git commit -m "feat: add test application manifests"
git push origin feature/pipeline-completo

# Aguardar validação e criar PR
# O workflow automaticamente criará PR para develop
```

** CHECKPOINT 8**: Pipeline completo validado

---

## 9. Troubleshooting

### 9.1 Problemas Comuns com Terraform

#### Erro de Backend Lock
```bash
# Verificar estado do lock
az storage blob list --container-name tfstate --account-name STORAGE_ACCOUNT_NAME --auth-mode login

# Forçar unlock (CUIDADO!)
terraform force-unlock LOCK_ID -chdir=terraform
```

#### Erro de Permissions
```bash
# Verificar permissões do Service Principal
az role assignment list --assignee CLIENT_ID --output table

# Verificar quota de recursos
az vm list-usage --location brazilsouth --output table
```

### 9.2 Problemas com GitHub Actions

#### Workflow Falha na Autenticação
```bash
# Verificar se secrets estão configurados corretamente
gh secret list

# Testar autenticação local
az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID
```

#### Timeout em Deploy
- Verificar quota de VMs na região
- Verificar se há recursos suficientes na subscription
- Verificar logs detalhados no Azure Portal

### 9.3 Problemas com AKS

#### Cluster não Cria
```bash
# Verificar disponibilidade da região
az vm list-skus --location brazilsouth --size Standard_B --output table

# Verificar quota
az vm list-usage --location brazilsouth --query "[?contains(name.value, 'cores')]" --output table
```

#### NGINX Ingress sem IP Externo
```bash
# Verificar service
kubectl describe svc nginx-ingress-nginx-ingress-controller -n nginx-ingress

# Verificar eventos
kubectl get events -n nginx-ingress --sort-by=.metadata.creationTimestamp
```

### 9.4 Scripts de Diagnóstico

```bash
# Script para verificar saúde geral
cat > diagnostico.sh << 'EOF'
#!/bin/bash
echo "=== DIAGNÓSTICO PIPELINE AKS ==="
echo "Data: $(date)"
echo

echo "1. Azure Login Status:"
az account show --output table

echo -e "\n2. Resource Groups:"
az group list --query "[?contains(name, 'MEU-NOME')]" --output table

echo -e "\n3. AKS Clusters:"
az aks list --output table

echo -e "\n4. Storage Accounts:"
az storage account list --query "[?contains(name, 'MEU-NOME')]" --output table

echo -e "\n5. GitHub Secrets:"
echo "Verificar via GitHub: Settings > Secrets and variables > Actions"

echo -e "\n6. Recent Workflow Runs:"
echo "Verificar via GitHub: Actions tab"

echo -e "\n=== FIM DIAGNÓSTICO ==="
EOF

chmod +x diagnostico.sh
./diagnostico.sh
```

** CHECKPOINT 9**: Troubleshooting preparado

---

## 10. Cleanup e Manutenção

### 10.1 Destroy de Ambiente Específico

```bash
# Via GitHub Actions (recomendado)
gh workflow run destroy-environment.yml -f environment=dev -f confirm_destroy=true

# Via Terraform local (emergência)
cd terraform
terraform init -backend-config="key=aks/dev.tfstate"
terraform destroy -var-file="dev/dev.tfvars" -auto-approve
```

### 10.2 Cleanup Completo

```bash
# Executar script de cleanup completo
./scripts/cleanup-all-infrastructure.sh

# Ou manual:
# Deletar todos os resource groups
az group delete --name MEU-NOME-devops-dev --yes --no-wait
az group delete --name MEU-NOME-devops-hml --yes --no-wait
az group delete --name MEU-NOME-devops-prd --yes --no-wait
az group delete --name MEU-NOME-terraform --yes --no-wait

# Deletar Service Principal
az ad sp delete --id ARM_CLIENT_ID
```

### 10.3 Monitoramento de Custos

```bash
# Verificar custos por resource group
az consumption usage list --query "[?contains(resourceGroup, 'MEU-NOME')]" --output table

# Script de monitoramento diário
cat > monitor-custos.sh << 'EOF'
#!/bin/bash
echo "=== RELATÓRIO DE CUSTOS AKS ==="
echo "Data: $(date)"
echo

for rg in MEU-NOME-devops-dev MEU-NOME-devops-hml MEU-NOME-devops-prd; do
    echo "Resource Group: $rg"
    az consumption usage list --query "[?resourceGroup=='$rg']" --output table
    echo
done
EOF

chmod +x monitor-custos.sh
```

---

## Resumo dos Arquivos Criados

### Estrutura Final do Projeto:
```
meu-aks-pipeline/
├── .github/workflows/
│   ├── 00-feature.yml           # Validação de features
│   ├── 01-develop.yml           # Deploy para DEV
│   ├── 02-homologacao.yml       # Deploy para HML
│   ├── 03-main.yml              # Deploy para PROD
│   └── destroy-environment.yml  # Destroy workflows
├── terraform/
│   ├── backend.tf               # Configuração do backend
│   ├── helm.tf                  # Helm charts (Argo Rollouts)
│   ├── ingress.tf               # NGINX Ingress Controller
│   ├── main.tf                  # Recursos principais AKS
│   ├── outputs.tf               # Outputs do Terraform
│   ├── providers.tf             # Providers Azure/Helm
│   ├── variables.tf             # Variáveis do Terraform
│   ├── dev/dev.tfvars          # Configuração DEV
│   ├── hml/hml.tfvars          # Configuração HML
│   └── prod/prod.tfvars        # Configuração PROD
├── scripts/
│   ├── setup-azure-infrastructure.sh  # Setup inicial Azure
│   ├── setup-service-principal.sh     # Setup Service Principal
│   └── cleanup-all-infrastructure.sh  # Cleanup completo
├── CLAUDE.md                    # Guia para Claude Code
├── README.md                    # Documentação do projeto
└── .gitignore                   # Arquivos ignorados pelo Git
```

### Links Úteis:
- [Azure CLI Documentation](https://docs.microsoft.com/en-us/cli/azure/)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Azure Kubernetes Service Documentation](https://docs.microsoft.com/en-us/azure/aks/)
- [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/)
- [Argo Rollouts Documentation](https://argoproj.github.io/argo-rollouts/)

---

## Próximos Passos

1. **Personalização Avançada**: Adicionar monitoring com Prometheus/Grafana
2. **Security**: Implementar Azure Key Vault para secrets
3. **Applications**: Deploy de aplicações reais usando Argo Rollouts
4. **Monitoring**: Configurar alertas e dashboards
5. **Backup**: Implementar backup do cluster e dados

** PARABÉNS! Seu pipeline AKS CI/CD está funcional e pronto para uso!**