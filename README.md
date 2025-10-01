# AKS CI/CD Pipeline - Test Mode

Este projeto demonstra um pipeline completo de CI/CD para Azure Kubernetes Service (AKS) usando GitHub Actions, Terraform e Helm.

## Modo de Teste

**IMPORTANTE**: Os workflows estão atualmente em **modo de teste** (simulação) para validar apenas o fluxo de branches sem executar deploys reais.

## Estrutura de Branches

### Fluxo de Desenvolvimento

```
feature/nova-funcionalidade
├── Pull Request → develop
├── Merge → develop (deploy DEV)
├── Merge → homologacao (deploy HML)
└── Merge → main (deploy PROD)
```

### Ambientes e Branches

| Branch | Ambiente | Trigger | Ação |
|--------|----------|---------|------|
| `feature/*` | Validação | Push/PR | Lint, Security, Validation |
| `develop` | DEV | Push | Deploy simulado para DEV |
| `homologacao` | HML | Push | Deploy simulado para HML |
| `main` | PROD | Push | Deploy simulado para PROD |

## Workflows Disponíveis

### 1. `deploy-aks.yml` - Pipeline Principal
- **Trigger**: Push para `develop`, `homologacao`, `main`
- **Ações**:
  - Determinação automática do ambiente
  - Validação de código
  - Deploy simulado com Terraform
  - Testes pós-deployment

### 2. `feature-validation.yml` - Validação de Features
- **Trigger**: Push para `feature/*`, `bugfix/*`, `hotfix/*` e Pull Requests
- **Ações**:
  - Lint de código Terraform
  - Validação de scripts
  - Análise de segurança
  - Verificação de qualidade

## Simulações Incluídas

Todos os comandos reais estão comentados e substituídos por simulações:

```yaml
# Real: terraform apply -auto-approve
echo "terraform apply -auto-approve"
echo "SUCCESS: Terraform deployment completed"
```

## Como Testar

### 1. Testar Feature Branch
```bash
git checkout -b feature/teste-workflow
git add .
git commit -m "Teste do workflow de feature"
git push origin feature/teste-workflow
```

### 2. Testar Deploy DEV
```bash
git checkout develop
git merge feature/teste-workflow
git push origin develop
```

### 3. Testar Deploy HML
```bash
git checkout homologacao
git merge develop
git push origin homologacao
```

### 4. Testar Deploy PROD
```bash
git checkout main
git merge homologacao
git push origin main
```

## Ativando Deploys Reais

Para ativar os deploys reais, descomente as seções nos workflows:

1. Azure Login
2. Terraform Setup
3. Terraform Commands
4. kubectl Commands

E configure os secrets necessários no GitHub:
- `AZURE_CREDENTIALS`
- `ARM_SUBSCRIPTION_ID`
- `ARM_ACCESS_KEY`

## Estrutura do Projeto

```
.
├── .github/workflows/
│   ├── deploy-aks.yml          # Pipeline principal
│   └── feature-validation.yml  # Validação de features
├── terraform/
│   ├── main.tf                 # Configuração AKS
│   ├── variables.tf            # Variáveis
│   ├── outputs.tf              # Outputs
│   ├── backend.tf              # Backend configuration
│   ├── ingress.tf              # NGINX Ingress
│   ├── helm.tf                 # Argo Rollouts
│   ├── dev/dev.tfvars          # Variáveis DEV
│   ├── hml/hml.tfvars          # Variáveis HML
│   └── prod/prod.tfvars        # Variáveis PROD
├── scripts/
│   ├── setup-azure-infrastructure.sh
│   ├── setup-service-principal.sh
│   └── cleanup-all-infrastructure.sh
└── README.md
```

## Status dos Workflows

Verifique o status dos workflows na aba **Actions** do repositório GitHub.