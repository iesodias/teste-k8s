# SETUP: Guia de Setup - Pipeline AKS CI/CD

Este guia fornece instruções passo-a-passo para configurar a pipeline completa de CI/CD para AKS.

## REQUIREMENTS: Pré-requisitos

### Azure
- [ ] Subscription do Azure com Owner permissions
- [ ] Resource quota suficiente para 3 clusters AKS
- [ ] Azure CLI instalado localmente (opcional)

### GitHub
- [ ] Repository GitHub criado
- [ ] GitHub Actions habilitado
- [ ] Permissions para manage repository secrets

### Ferramentas Locais (Recomendado)
- [ ] [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) >= 2.45.0
- [ ] [Terraform](https://www.terraform.io/downloads) >= 1.6.0
- [ ] [Git](https://git-scm.com/downloads) >= 2.30.0

## STEP: Setup Passo-a-Passo

### Etapa 1: Configuração Azure

#### 1.1 Login no Azure
```bash
# Login interativo
az login

# Verificar subscription ativa
az account show

# Mudar subscription se necessário
az account set --subscription "SUBSCRIPTION_ID"
```

#### 1.2 Verificar Quotas
```bash
# Verificar quota de cores disponíveis
az vm list-usage --location brazilsouth --query "[?name.value=='cores']"

# Verificar quota de clusters AKS
az aks list --query "length(@)"
```

#### 1.3 Executar Setup de Infraestrutura Base
```bash
# Clonar repositório
git clone https://github.com/your-org/udemy-k8s-gh.git
cd udemy-k8s-gh

# Executar script de setup
chmod +x scripts/setup-azure-infrastructure.sh
./scripts/setup-azure-infrastructure.sh
```

**Output Esperado:**
```
SETUP: Setting up Azure infrastructure for AKS CI/CD Pipeline...
CREATING: Creating Terraform state Resource Group...
SUCCESS: Resource Group 'gh-terraform' created successfully
STORAGE: Creating Storage Account for Terraform state...
SUCCESS: Storage Account 'ghdevopsautomatf' created successfully
CONTAINER: Creating container for Terraform state...
SUCCESS: Container 'tfstate' created successfully
ENVIRONMENT: Creating environment Resource Groups...
SUCCESS: Resource Group 'gh-devops-dev' created successfully
SUCCESS: Resource Group 'gh-devops-hml' created successfully
SUCCESS: Resource Group 'gh-devops-prd' created successfully

SUCCESS: Azure infrastructure setup completed!

CONFIG: Backend configuration for Terraform:
--------------------------------------------
resource_group_name  = "gh-terraform"
storage_account_name = "ghdevopsautomatf"
container_name       = "tfstate"
key                  = "aks/{environment}.tfstate"

KEY: Storage Account Key (for GitHub Secrets):
ARM_ACCESS_KEY=ABC123...
```

### Etapa 2: Service Principal

#### 2.1 Criar Service Principal
```bash
# Executar script de Service Principal
chmod +x scripts/setup-service-principal.sh
./scripts/setup-service-principal.sh
```

**Output Esperado:**
```json
{
  "clientId": "12345678-1234-1234-1234-123456789012",
  "clientSecret": "ABC123...",
  "subscriptionId": "87654321-4321-4321-4321-210987654321",
  "tenantId": "11111111-1111-1111-1111-111111111111",
  "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
  "resourceManagerEndpointUrl": "https://management.azure.com/",
  "activeDirectoryGraphResourceId": "https://graph.windows.net/",
  "sqlManagementEndpointUrl": "https://management.core.windows.net:8443/",
  "galleryEndpointUrl": "https://gallery.azure.com/",
  "managementEndpointUrl": "https://management.core.windows.net/"
}
```

### Etapa 3: GitHub Configuration

#### 3.1 Configurar Repository Secrets

Navegue para: `Settings` → `Secrets and variables` → `Actions`

**Required Secrets:**

| Nome | Valor | Exemplo |
|------|-------|---------|
| `AZURE_CREDENTIALS` | Todo JSON output do Service Principal | `{"clientId": "...", ...}` |
| `ARM_CLIENT_ID` | clientId do Service Principal | `12345678-1234-...` |
| `ARM_CLIENT_SECRET` | clientSecret do Service Principal | `ABC123...` |
| `ARM_SUBSCRIPTION_ID` | subscriptionId | `87654321-4321-...` |
| `ARM_TENANT_ID` | tenantId | `11111111-1111-...` |
| `ARM_ACCESS_KEY` | Storage Account Key do step 1.3 | `def456...` |

**Optional Secrets:**

| Nome | Valor | Descrição |
|------|-------|-----------|
| `TEAMS_WEBHOOK_URL` | Teams webhook URL | Para notificações |
| `INFRACOST_API_KEY` | Infracost API key | Para estimativas de custo |

#### 3.2 Configurar Environment Protection Rules

**Development Environment:**
1. Go to `Settings` → `Environments`
2. Create environment: `dev`
3. No protection rules needed

**Homologation Environment:**
1. Create environment: `hml`
2. Add protection rule: `Required reviewers` = 1
3. Add allowed branches: `homologacao`

**Production Environment:**
1. Create environment: `prod`
2. Add protection rule: `Required reviewers` = 2
3. Add `Deployment branches`: `main` only
4. Optional: Set deployment window

### Etapa 4: Teste da Pipeline

#### 4.1 Teste Inicial - Feature Branch
```bash
# Criar feature branch
git checkout -b feature/initial-setup

# Fazer uma pequena mudança
echo "# Pipeline Test" >> test.md
git add test.md
git commit -m "feat: initial pipeline test"

# Push para trigger validation
git push origin feature/initial-setup
```

**Verificar:**
- [ ] Workflow "Feature Branch Validation" executou
- [ ] Todos os checks passaram
- [ ] Comments apareceram no PR (se criado)

#### 4.2 Teste Deploy Development
```bash
# Criar PR para develop
gh pr create --base develop --title "feat: initial setup test"

# Merge PR
gh pr merge --merge

# Aguardar deploy automático
```

**Verificar:**
- [ ] Workflow "Deploy AKS Infrastructure" executou
- [ ] Cluster AKS criado em `gh-devops-dev`
- [ ] NGINX Ingress instalado
- [ ] Argo Rollouts instalado
- [ ] PR automático criado: develop → homologacao

#### 4.3 Validar Cluster AKS
```bash
# Conectar ao cluster
az aks get-credentials \
  --resource-group gh-devops-dev \
  --name aks-devops-dev

# Verificar cluster
kubectl cluster-info
kubectl get nodes
kubectl get namespaces

# Verificar NGINX Ingress
kubectl get pods -n nginx-ingress
kubectl get services -n nginx-ingress

# Verificar Argo Rollouts
kubectl get pods -n argo-rollouts
```

**Output Esperado:**
```
# Nodes
NAME                                STATUS   ROLES   AGE   VERSION
aks-system-12345678-vmss000000     Ready    agent   5m    v1.28.x

# NGINX Ingress
NAME                                               READY   STATUS    RESTARTS   AGE
nginx-ingress-controller-12345678-abcde           1/1     Running   0          3m

# Argo Rollouts
NAME                                      READY   STATUS    RESTARTS   AGE
argo-rollouts-controller-12345678-abcde  1/1     Running   0          3m
```

### Etapa 5: Configurações Avançadas

#### 5.1 Configurar Notificações Teams (Opcional)
```bash
# 1. Criar webhook no Teams channel
# 2. Adicionar URL como GitHub Secret: TEAMS_WEBHOOK_URL
# 3. Testar próximo deploy para verificar notificação
```

#### 5.2 Configurar Cost Monitoring (Opcional)
```bash
# 1. Criar conta no Infracost.io
# 2. Obter API key
# 3. Adicionar como GitHub Secret: INFRACOST_API_KEY
# 4. Próximo PR mostrará estimativas de custo
```

#### 5.3 Configurar Monitoring Dashboard
```bash
# Acessar Log Analytics Workspace
az monitor log-analytics workspace show \
  --resource-group gh-devops-dev \
  --workspace-name law-aks-devops-dev \
  --query id -o tsv

# URL do workspace será:
# https://portal.azure.com/#@TENANT_ID/resource/WORKSPACE_ID
```

## SUCCESS: Checklist Final

### Infraestrutura
- [ ] Resource Groups criados (gh-terraform, gh-devops-dev, gh-devops-hml, gh-devops-prd)
- [ ] Storage Account criado (ghdevopsautomatf)
- [ ] Service Principal criado e testado

### GitHub
- [ ] Todos os secrets configurados
- [ ] Environment protection rules configuradas
- [ ] Workflows executando sem erros

### AKS Clusters
- [ ] Cluster dev criado e funcional
- [ ] NGINX Ingress funcionando
- [ ] Argo Rollouts funcionando
- [ ] Conectividade kubectl confirmada

### Pipeline
- [ ] Feature branch validation funcionando
- [ ] Deploy automático dev funcionando
- [ ] Promoção automática funcionando
- [ ] Testes pós-deploy passando

## TROUBLESHOOTING: Troubleshooting

### Problema: Service Principal sem permissões
```bash
# Verificar roles do SP
az role assignment list --assignee $ARM_CLIENT_ID --output table

# Adicionar role se necessário
az role assignment create \
  --assignee $ARM_CLIENT_ID \
  --role Contributor \
  --scope /subscriptions/$ARM_SUBSCRIPTION_ID
```

### Problema: Storage Account sem acesso
```bash
# Verificar acesso ao Storage Account
az storage account show \
  --name ghdevopsautomatf \
  --resource-group gh-terraform

# Regenerar chave se necessário
az storage account keys renew \
  --name ghdevopsautomatf \
  --resource-group gh-terraform \
  --key key1
```

### Problema: Terraform state lock
```bash
# Verificar locks
az storage blob list \
  --account-name ghdevopsautomatf \
  --container-name tfstate \
  --prefix aks/

# Remover lock se necessário (CUIDADO!)
# terraform force-unlock LOCK_ID
```

### Problema: Quota insuficiente
```bash
# Verificar quota atual
az vm list-usage --location brazilsouth \
  --query "[?name.value=='cores'].{Name:name.value,Current:currentValue,Limit:limit}"

# Solicitar aumento de quota no portal Azure
```

##  Suporte

Se você encontrar problemas durante o setup:

1. **Verificar Logs**: GitHub Actions → Workflow específico → View logs
2. **Verificar Azure**: Portal Azure → Resource Groups → Verificar recursos
3. **Verificar Terraform**: State files no Storage Account
4. **Documentação**: README.md para troubleshooting adicional

## SUCCESS: Próximos Passos

Após completar o setup:

1. **Testar Pipeline Completa**: dev → hml → prod
2. **Configurar Aplicações**: Deploy de aplicações reais
3. **Monitoramento**: Configurar dashboards e alertas
4. **Backup**: Estratégia de backup dos clusters
5. **Security**: Review de segurança e compliance

---

**Setup concluído com sucesso! SETUP:**