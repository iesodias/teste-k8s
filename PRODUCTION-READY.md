## PRODUCTION READY - AKS CI/CD Pipeline

## IMPLEMENTAÇÃO COMPLETA

A pipeline AKS CI/CD está **100% funcional** com comandos Terraform reais implementados em todos os workflows.

## FLUXO IMPLEMENTADO

### 1. Feature Validation (00-feature.yml)
- **Trigger**: Push em `feature/*`, `bugfix/*`, `hotfix/*`
- **Ações**:
  - Terraform format check real
  - Terraform validation real
  - Plan validation para todos os ambientes
  - Criação automática de PR para `develop`

### 2. DEV Deploy (01-develop.yml)
- **Trigger**: Push em `develop`
- **Ações**:
  - Login Azure com Service Principal
  - Terraform init com backend `aks/dev.tfstate`
  - Terraform apply real no ambiente DEV
  - Configuração kubectl para aks-devops-dev
  - Testes de conectividade e validação
  - Criação automática de PR para `homologacao`

### 3. HML Deploy (02-homologacao.yml)
- **Trigger**: Push em `homologacao`
- **Ações**:
  - Login Azure com Service Principal
  - Terraform init com backend `aks/hml.tfstate`
  - Terraform apply real no ambiente HML
  - Configuração kubectl para aks-devops-hml
  - Testes de integração completos
  - Criação automática de PR para `main`

### 4. PROD Deploy (03-main.yml)
- **Trigger**: Pull Request para `main`
- **Ações**:
  - Validação Terraform para PROD
  - Deploy real no ambiente PROD
  - Configuração kubectl para aks-devops-prod
  - Verificações pós-deploy avançadas
  - **Auto-merge se sucesso** / **Rollback se falha**

## RECURSOS IMPLEMENTADOS

### Terraform Real
-  `terraform fmt -check`
-  `terraform init` com backend Azure Storage
-  `terraform validate`
-  `terraform plan` com tfvars específicos
-  `terraform apply` com auto-approve
-  `terraform destroy` para rollback

### Azure Integration
-  Azure Login com Service Principal
-  AKS credentials automáticos (`az aks get-credentials`)
-  Backend state no Azure Storage
-  Keys separadas por ambiente

### Kubernetes Validation
-  `kubectl cluster-info`
-  `kubectl get nodes`
-  `kubectl get pods` para todos os namespaces
-  `kubectl wait` para readiness das aplicações
-  Validação de LoadBalancer services

### Helm Charts Deployment
-  NGINX Ingress Controller via Terraform
-  Argo Rollouts via Terraform
-  Configuração automática via Helm provider

## SECRETS NECESSÁRIOS (OTIMIZADO)

Configure no GitHub: `Settings` → `Secrets and variables` → `Actions`

**APENAS 3 SECRETS NECESSÁRIOS:**

```
AZURE_CREDENTIALS         = {"clientId": "...", "clientSecret": "...", ...}
ARM_ACCESS_KEY           = Storage Account Access Key
TOKEN_GB                 = GitHub Personal Access Token
```

**SIMPLIFICAÇÃO**: Removemos ARM_CLIENT_* individuais! O Terraform provider herda automaticamente as credenciais do Azure CLI via AZURE_CREDENTIALS.

## PRÉ-REQUISITOS

### 1. Infraestrutura Azure
Execute os scripts de setup:
```bash
# Setup da infraestrutura base
./scripts/setup-azure-infrastructure.sh

# Setup do Service Principal
./scripts/setup-service-principal.sh
```

### 2. Resource Groups Criados
- `gh-terraform` (Storage Account para states)
- `gh-devops-dev` (Ambiente DEV)
- `gh-devops-hml` (Ambiente HML)
- `gh-devops-prd` (Ambiente PROD)

### 3. Storage Account
- Nome: `ghdevopsautomatf`
- Container: `tfstate`
- Keys: `aks/dev.tfstate`, `aks/hml.tfstate`, `aks/prod.tfstate`

## COMO USAR

### 1. Desenvolvimento
```bash
git checkout -b feature/nova-funcionalidade
# Faça suas alterações
git push origin feature/nova-funcionalidade
# Workflow 00-feature.yml executa + cria PR para develop
```

### 2. Deploy DEV
```bash
# Merge do PR feature → develop
# Workflow 01-develop.yml executa automaticamente
# Deploy real no AKS DEV + cria PR para homologacao
```

### 3. Deploy HML
```bash
# Merge do PR develop → homologacao
# Workflow 02-homologacao.yml executa automaticamente
# Deploy real no AKS HML + cria PR para main
```

### 4. Deploy PROD
```bash
# PR homologacao → main é criado automaticamente
# Workflow 03-main.yml executa na abertura do PR
# Deploy real no AKS PROD + auto-merge se sucesso
```

## VERIFICAÇÕES

### Clusters AKS Criados
```bash
# DEV
az aks show --resource-group gh-devops-dev --name aks-devops-dev

# HML
az aks show --resource-group gh-devops-hml --name aks-devops-hml

# PROD
az aks show --resource-group gh-devops-prd --name aks-devops-prod
```

### Conectividade kubectl
```bash
# Conectar ao DEV
az aks get-credentials --resource-group gh-devops-dev --name aks-devops-dev

# Verificar pods
kubectl get pods -A
kubectl get svc -A
```

## MONITORAMENTO

### GitHub Actions
- Acompanhe execuções em: `https://github.com/USER/REPO/actions`
- Logs detalhados de cada step
- Notificação automática em caso de falha

### Azure Portal
- Clusters AKS nos Resource Groups respectivos
- Logs e métricas via Azure Monitor
- Service Principal e permissões

## ROLLBACK

### Automático
- Falha no PROD → Rollback automático via `terraform destroy`
- PR permanece aberto para investigação

### Manual
```bash
# Rollback via Terraform
cd terraform
terraform init -backend-config="key=aks/ENVIRONMENT.tfstate"
terraform destroy -var-file="ENVIRONMENT/ENVIRONMENT.tfvars"
```

---

**STATUS: PRODUÇÃO **

Pipeline 100% funcional com Terraform real, pronta para uso em produção.