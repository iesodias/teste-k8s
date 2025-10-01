# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an **AKS CI/CD Pipeline** project demonstrating complete Infrastructure as Code (IaC) with automated multi-environment deployment strategy using Terraform, GitHub Actions, and Azure Kubernetes Service.

## Commands

### Initial Setup
- **Setup Azure infrastructure**: `./scripts/setup-azure-infrastructure.sh`
- **Setup Service Principal**: `./scripts/setup-service-principal.sh`
- **Navigate to terraform directory**: `cd terraform`

### Terraform Management
- **Initialize with backend**: `terraform init -backend-config="key=aks/{environment}.tfstate"`
- **Validate configuration**: `terraform validate`
- **Format code**: `terraform fmt -recursive`
- **Plan for environment**: `terraform plan -var-file="{env}/{env}.tfvars"`
- **Apply infrastructure**: `terraform apply -var-file="{env}/{env}.tfvars"`
- **Destroy infrastructure**: `terraform destroy -var-file="{env}/{env}.tfvars"`

### Kubernetes Operations
- **Connect to cluster**: `az aks get-credentials --resource-group gh-devops-{env} --name aks-devops-{env}`
- **Check cluster status**: `kubectl cluster-info`
- **List nodes**: `kubectl get nodes`
- **Check NGINX Ingress**: `kubectl get pods -n nginx-ingress`
- **Check Argo Rollouts**: `kubectl get pods -n argo-rollouts`

### GitHub Actions
- **Manual deployment**: Use workflow_dispatch on `DEPLOY: Deploy AKS Infrastructure`
- **View logs**: Check workflow runs in Actions tab
- **Feature validation**: Automatic on feature branch pushes
- **Environment promotion**: Automatic PR creation after successful deploys

## Architecture

### Multi-Environment Strategy
- **Development**: `gh-devops-dev` → `aks-devops-dev` (develop branch)
- **Homologation**: `gh-devops-hml` → `aks-devops-hml` (homologacao branch)
- **Production**: `gh-devops-prd` → `aks-devops-prod` (main branch)

### Repository Structure
```
├── .github/workflows/           # CI/CD pipelines
│   ├── deploy-aks.yml          # Main deployment workflow
│   ├── feature-validation.yml  # Feature branch validation
│   └── promote-environments.yml # Auto-promotion workflow
├── terraform/                   # Infrastructure as Code
│   ├── {env}/{env}.tfvars      # Environment-specific variables
│   ├── main.tf                 # AKS cluster resources
│   ├── ingress.tf             # NGINX Ingress Controller
│   ├── helm.tf                # Argo Rollouts
│   └── *.tf                   # Other Terraform files
├── scripts/                    # Setup automation scripts
└── docs/                      # Documentation
```

### Azure Resources Architecture
- **State Management**: `gh-terraform` RG → `ghdevopsautomatf` Storage → `tfstate` container
- **AKS Clusters**: Separate clusters per environment with optimized configurations
- **Networking**: Dedicated VNets, subnets, and NSGs per environment
- **Monitoring**: Log Analytics workspace integration
- **Helm Charts**: NGINX Ingress Controller + Argo Rollouts

## CI/CD Pipeline Flow

### 1. Feature Development
- **Branch**: `feature/*` → Validation only (terraform plan, security scan, cost estimation)
- **Validation**: Format, validate, security scan, cost estimation

### 2. Development Deploy
- **Branch**: `develop` → Auto-deploy to DEV environment
- **Actions**: Plan → Apply → Post-deploy tests → Auto-create PR to homologacao

### 3. Homologation Deploy
- **Branch**: `homologacao` → Auto-deploy to HML environment
- **Actions**: Plan → Apply → Post-deploy tests → Auto-create PR to main

### 4. Production Deploy
- **Branch**: `main` → Auto-deploy to PROD environment
- **Actions**: Plan → Apply → Post-deploy tests → Teams notifications

## Key Technologies
- **Cloud Provider**: Microsoft Azure
- **Container Orchestration**: Azure Kubernetes Service (AKS)
- **Infrastructure as Code**: Terraform v1.6+ (azurerm provider v3.80+)
- **CI/CD**: GitHub Actions with environment protection
- **Service Mesh**: NGINX Ingress Controller
- **Progressive Delivery**: Argo Rollouts
- **Monitoring**: Azure Log Analytics + Azure Monitor
- **State Management**: Azure Storage Backend with environment separation

## Authentication and Secrets

### Required GitHub Secrets
- **AZURE_CREDENTIALS**: Complete Service Principal JSON
- **ARM_CLIENT_ID**: Service Principal client ID
- **ARM_CLIENT_SECRET**: Service Principal client secret
- **ARM_SUBSCRIPTION_ID**: Azure subscription ID
- **ARM_TENANT_ID**: Azure AD tenant ID
- **ARM_ACCESS_KEY**: Storage Account access key

### Optional Secrets
- **TEAMS_WEBHOOK_URL**: For Teams notifications
- **INFRACOST_API_KEY**: For cost estimation

## Environment Configuration

### Development (dev)
- **Resources**: Minimal (Standard_B2s, 1-3 nodes)
- **Features**: HTTP routing enabled, single node pool
- **Monitoring**: 7-day log retention

### Homologation (hml)
- **Resources**: Medium (Standard_B2ms, 1-4 nodes)
- **Features**: Additional app node pool, enhanced monitoring
- **Monitoring**: 30-day log retention

### Production (prod)
- **Resources**: High (Standard_D2s_v3, 2-10 nodes)
- **Features**: Multi-node pools, enhanced security, backup
- **Monitoring**: 90-day log retention

## Common Troubleshooting

### Terraform State Issues
- **Lock conflicts**: Check storage account container for lease status
- **State corruption**: Use `terraform import` to recover resources
- **Backend errors**: Verify ARM_ACCESS_KEY and storage account permissions

### AKS Deployment Issues
- **Node provisioning**: Check Azure quota limits and VM availability
- **Network connectivity**: Verify subnet address spaces don't overlap
- **RBAC errors**: Ensure Service Principal has AKS permissions

### GitHub Actions Issues
- **Authentication failures**: Verify all required secrets are set
- **Environment protection**: Check if approvals are required
- **Workflow permissions**: Verify GITHUB_TOKEN has necessary scopes

### Helm Chart Issues
- **NGINX Ingress**: Check Load Balancer service creation and external IP
- **Argo Rollouts**: Verify controller logs and CRD installation
- **Resource limits**: Adjust requests/limits based on environment

## Development Workflow
1. Create feature branch: `git checkout -b feature/new-feature`
2. Make changes and push: Triggers validation workflow
3. Create PR to develop: Review validation results
4. Merge to develop: Auto-deploy to DEV + create PR to homologacao
5. Approve and merge to homologacao: Auto-deploy to HML + create PR to main
6. Approve and merge to main: Auto-deploy to PROD

## Cost Management
- **Dev**: ~$50/month (minimal resources)
- **HML**: ~$120/month (medium resources)
- **Prod**: ~$300/month (production resources)
- **Monitoring**: Infracost integration for cost estimation on PRs