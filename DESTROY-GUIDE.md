# Destroy Environment Guide

## WORKFLOW DE DESTRUIÇÃO

O workflow `destroy-environment.yml` permite destruir qualquer ambiente (DEV/HML/PROD) de forma segura e controlada.

## COMO USAR

### 1. Acesso ao Workflow
```
GitHub → Actions → "Destroy Environment" → Run workflow
```

### 2. Configuração
- **Environment**: Escolha `dev`, `hml` ou `prod`
- **Confirm destruction**:  Marque para confirmar

### 3. Execução
- Clique em **"Run workflow"**
- Acompanhe os logs em tempo real

## O QUE É DESTRUÍDO

###  Recursos Terraform (Destruídos)
- **AKS Cluster**: `aks-devops-{env}`
- **NGINX Ingress Controller** (via Helm)
- **Argo Rollouts** (via Helm)
- **Load Balancers** associados
- **Network Security Groups**

###  Recursos Preservados
- **Resource Group**: `gh-devops-{env}` (não é gerenciado pelo Terraform)
- **Storage Account**: `ghdevopsautomatf` (backend)
- **Terraform State**: `aks/{env}.tfstate` (preservado para histórico)

## PROCESSO TÉCNICO

### 1. Validação
```bash
# Verifica confirmação obrigatória
if [ "$confirm_destruction" != "true" ]; then
  exit 1
fi
```

### 2. Inicialização
```bash
# Conecta ao state específico do ambiente
terraform init -backend-config="key=aks/{env}.tfstate"
```

### 3. Preparação
```bash
# Sincroniza state com Azure
terraform refresh -var-file="{env}/{env}.tfvars"

# Cria plano de destruição
terraform plan -destroy -out=destroy.tfplan
```

### 4. Execução
```bash
# Executa destruição
terraform apply -auto-approve destroy.tfplan
```

### 5. Verificação
```bash
# Confirma que cluster foi destruído
az aks show --resource-group gh-devops-{env} --name aks-devops-{env}
```

## SEGURANÇA

###  Proteções Implementadas
- **Manual trigger apenas** (workflow_dispatch)
- **Confirmação obrigatória** (checkbox)
- **Timeout de 30 minutos** (evita travamento)
- **Logs detalhados** de cada step
- **Verificação pós-destruição**

###  Avisos Importantes
- **Destruição é irreversível**
- **Dados da aplicação serão perdidos**
- **Backup necessário antes da execução**
- **Apenas administradores devem executar**

## EXEMPLO DE USO

### Cenário: Destruir ambiente DEV
1. Vá para **GitHub → Actions**
2. Selecione **"Destroy Environment"**
3. Clique **"Run workflow"**
4. Configure:
   - Environment: `dev`
   - Confirm: 
5. Clique **"Run workflow"**
6. Aguarde **~15 minutos** para conclusão

### Logs Esperados
```
=== DESTROY ENVIRONMENT VALIDATION ===
Environment to destroy: dev
Confirmation: true
PASSED: Destruction confirmed for dev environment

=== TERRAFORM DESTROY PREPARATION ===
Environment: dev
Terraform has been successfully initialized!
PASSED: Destroy plan created for dev environment

=== DESTROYING dev ENVIRONMENT ===
WARNING: This will destroy all resources in dev environment
Starting destruction in 5 seconds...
Apply complete! Resources: 0 added, 0 changed, 8 destroyed.
SUCCESS: dev environment destroyed successfully

=== DESTRUCTION VERIFICATION ===
SUCCESS: AKS cluster aks-devops-dev has been destroyed
COMPLETED: Destruction verification finished

=== DESTRUCTION SUMMARY ===
Environment: dev
Status: success
SUCCESS: Environment dev destroyed successfully
```

## RECRIAR AMBIENTE

Após destruição, para recriar:

### 1. Via Pipeline Normal
```bash
git checkout -b feature/recriar-dev
git push origin feature/recriar-dev
# Segue fluxo normal: feature → develop → deploy DEV
```

### 2. Via Deploy Manual
```
GitHub → Actions → "DEV Deploy and Promote to HML" → Run workflow
```

## TROUBLESHOOTING

### Erro: "Backend initialization required"
```bash
# State corrompido, reinicialize
terraform init -reconfigure -backend-config="key=aks/{env}.tfstate"
```

### Erro: "Resource still exists"
```bash
# Alguns recursos podem estar órfãos, destrua manualmente no Portal Azure
```

### Timeout durante destruição
```bash
# Load Balancer pode demorar, aguarde até 30 minutos
```

---

**IMPORTANTE**: Use com responsabilidade. Destruição é irreversível.