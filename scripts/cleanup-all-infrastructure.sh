#!/bin/bash

# =============================================================================
# CLEANUP SCRIPT - AKS CI/CD Project Infrastructure (Reverse Engineering)
# =============================================================================
# Este script faz a engenharia reversa dos scripts de setup para remover
# TODA a infraestrutura criada pelos seguintes scripts:
# - setup-azure-infrastructure.sh
# - setup-service-principal.sh
#
# ATENÇÃO: Esta operação é IRREVERSÍVEL!
# =============================================================================

set -e  # Exit on any error

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# =============================================================================
# CONFIGURAÇÕES BASEADAS NOS SCRIPTS DE SETUP (ENGENHARIA REVERSA)
# =============================================================================

# Do script setup-azure-infrastructure.sh
LOCATION="brazilsouth"
TERRAFORM_RG="gh-terraform"
STORAGE_ACCOUNT="ghdevopsautomatf"
CONTAINER_NAME="tfstate"

# Environment Resource Groups
DEV_RG="gh-devops-dev"
HML_RG="gh-devops-hml"
PRD_RG="gh-devops-prd"

# Do script setup-service-principal.sh
SP_NAME="sp-github-actions-aks"

# Lista completa de Resource Groups criados
ALL_RESOURCE_GROUPS=("$TERRAFORM_RG" "$DEV_RG" "$HML_RG" "$PRD_RG")

# =============================================================================
# FUNÇÕES AUXILIARES
# =============================================================================

# Função para exibir banner
show_banner() {
    echo -e "${RED}"
    echo "============================================================================="
    echo "               CLEANUP REVERSO - AKS CI/CD Infrastructure"
    echo "============================================================================="
    echo -e "${NC}"
    echo -e "${YELLOW}  ENGENHARIA REVERSA DOS SCRIPTS DE SETUP${NC}"
    echo ""
    echo "Recursos que serão removidos (baseado nos scripts):"
    echo "├──  Resource Groups:"
    echo "│   ├── $TERRAFORM_RG (Terraform state)"
    echo "│   ├── $DEV_RG (Development)"
    echo "│   ├── $HML_RG (Homologation)"
    echo "│   └── $PRD_RG (Production)"
    echo "├──   Storage Account: $STORAGE_ACCOUNT"
    echo "├──  Container: $CONTAINER_NAME"
    echo "├──  Service Principal: $SP_NAME"
    echo "└──  Todos os recursos AKS dentro dos RGs"
    echo ""
}

# Função para confirmar ação
confirm_deletion() {
    echo -e "${RED}  CONFIRMAÇÃO NECESSÁRIA ${NC}"
    echo ""
    echo "Esta operação faz a ENGENHARIA REVERSA dos scripts:"
    echo "• setup-azure-infrastructure.sh"
    echo "• setup-service-principal.sh"
    echo ""
    echo "Recursos que serão REMOVIDOS:"
    echo "• Todos os clusters AKS (dev/hml/prd)"
    echo "• Storage Account do Terraform ($STORAGE_ACCOUNT)"
    echo "• Service Principal ($SP_NAME)"
    echo "• Todos os Resource Groups do projeto"
    echo ""

    read -p "Digite 'DELETE-ALL' para confirmar a exclusão total: " confirmation

    if [ "$confirmation" != "DELETE-ALL" ]; then
        echo -e "${YELLOW} Operação cancelada pelo usuário.${NC}"
        exit 1
    fi

    echo -e "${GREEN} Confirmação recebida. Iniciando engenharia reversa...${NC}"
    echo ""
}

# Função para verificar se o usuário está logado no Azure
check_azure_login() {
    echo -e "${BLUE} Verificando login no Azure...${NC}"

    if ! az account show &>/dev/null; then
        echo -e "${RED} Você não está logado no Azure CLI.${NC}"
        echo "Execute: az login"
        exit 1
    fi

    local subscription=$(az account show --query name -o tsv)
    local subscription_id=$(az account show --query id -o tsv)
    echo -e "${GREEN} Logado na subscription: ${subscription}${NC}"
    echo -e "${GREEN}   Subscription ID: ${subscription_id}${NC}"
    echo ""
}

# Função para deletar Service Principal (reverso do setup-service-principal.sh)
delete_service_principal() {
    echo -e "${BLUE} Removendo Service Principal (reverso do setup)...${NC}"

    # Verificar se SP existe
    local sp_exists=$(az ad sp list --display-name "$SP_NAME" --query "[].appId" -o tsv 2>/dev/null || echo "")

    if [ -n "$sp_exists" ]; then
        echo -e "${RED} Deletando Service Principal: $SP_NAME${NC}"
        az ad sp delete --id "$sp_exists"
        echo -e "${GREEN} Service Principal removido: $SP_NAME${NC}"
    else
        echo -e "${YELLOW} Service Principal não encontrado: $SP_NAME${NC}"
    fi

    echo ""
}

# Função para deletar Resource Groups (reverso do setup-azure-infrastructure.sh)
delete_resource_groups() {
    echo -e "${BLUE} Removendo Resource Groups (reverso do setup)...${NC}"

    for rg in "${ALL_RESOURCE_GROUPS[@]}"; do
        echo -e "${YELLOW} Verificando Resource Group: ${rg}${NC}"

        if az group exists --name "$rg" &>/dev/null; then
            echo -e "${RED} Deletando Resource Group: ${rg}${NC}"

            # Deletar RG sem confirmação (já confirmamos acima)
            az group delete --name "$rg" --yes --no-wait

            echo -e "${GREEN} Comando de deleção enviado para: ${rg}${NC}"
        else
            echo -e "${YELLOW} Resource Group não encontrado: ${rg}${NC}"
        fi
    done

    echo ""
}

# Função para confirmar comandos de deleção executados
confirm_deletion_commands() {
    echo -e "${BLUE} Comandos de deleção executados com sucesso!${NC}"
    echo -e "${YELLOW}Os recursos estão sendo deletados em background pelo Azure...${NC}"
    echo ""

    echo -e "${BLUE} Comandos executados:${NC}"
    echo "• Service Principal deletado: $SP_NAME"
    echo "• Resource Groups sendo deletados:"
    for rg in "${ALL_RESOURCE_GROUPS[@]}"; do
        echo "  - $rg"
    done
    echo "• Contextos kubectl limpos"
    echo ""

    echo -e "${YELLOW} IMPORTANTE: A deleção acontece em background${NC}"
    echo -e "${BLUE}Storage Accounts podem demorar até 20 minutos para serem completamente removidos pelo Azure${NC}"
    echo ""
}

# Função para orientar verificação no Portal Azure
show_azure_portal_instructions() {
    echo -e "${BLUE} VERIFICAÇÃO NO PORTAL AZURE${NC}"
    echo ""
    echo -e "${YELLOW}Para acompanhar o progresso da deleção:${NC}"
    echo ""
    echo -e "${BLUE}1. Acesse: https://portal.azure.com${NC}"
    echo -e "${BLUE}2. Vá em 'Resource Groups'${NC}"
    echo -e "${BLUE}3. Verifique se os seguintes grupos foram removidos:${NC}"
    for rg in "${ALL_RESOURCE_GROUPS[@]}"; do
        echo "   • $rg"
    done
    echo ""
    echo -e "${BLUE}4. Vá em 'Storage Accounts' para verificar:${NC}"
    echo "   • $STORAGE_ACCOUNT (pode demorar mais)"
    echo ""
    echo -e "${BLUE}5. Em 'Azure Active Directory' > 'App registrations':${NC}"
    echo "   • Verifique se $SP_NAME foi removido"
    echo ""
    echo -e "${GREEN} DICA: Recursos podem levar alguns minutos para desaparecer da interface${NC}"
    echo ""
}

# Função para limpar contextos kubectl
cleanup_kubectl_contexts() {
    echo -e "${BLUE} Limpando contextos kubectl relacionados...${NC}"

    local contexts=$(kubectl config get-contexts -o name 2>/dev/null | grep -E "(aks-devops|gh-devops)" || true)

    if [ -n "$contexts" ]; then
        echo "$contexts" | while read -r context; do
            echo -e "${YELLOW} Removendo contexto: ${context}${NC}"
            kubectl config delete-context "$context" &>/dev/null || true
        done
        echo -e "${GREEN} Contextos kubectl limpos${NC}"
    else
        echo -e "${GREEN} Nenhum contexto kubectl relacionado encontrado${NC}"
    fi

    echo ""
}

# Função para mostrar detalhes dos scripts originais
show_reverse_engineering_info() {
    echo -e "${BLUE} Engenharia Reversa - Scripts Analisados:${NC}"
    echo ""
    echo -e "${YELLOW}1. setup-azure-infrastructure.sh:${NC}"
    echo "   ├── Resource Group: $TERRAFORM_RG"
    echo "   ├── Storage Account: $STORAGE_ACCOUNT"
    echo "   ├── Container: $CONTAINER_NAME"
    echo "   ├── DEV RG: $DEV_RG"
    echo "   ├── HML RG: $HML_RG"
    echo "   └── PRD RG: $PRD_RG"
    echo ""
    echo -e "${YELLOW}2. setup-service-principal.sh:${NC}"
    echo "   └── Service Principal: $SP_NAME"
    echo ""
}

# Função principal
main() {
    show_banner
    show_reverse_engineering_info
    check_azure_login
    confirm_deletion

    echo -e "${RED} Iniciando engenharia reversa da infraestrutura...${NC}"
    echo ""

    delete_service_principal
    delete_resource_groups
    cleanup_kubectl_contexts
    confirm_deletion_commands
    show_azure_portal_instructions

    echo -e "${GREEN}"
    echo "============================================================================="
    echo "                    COMANDO DE DELEÇÃO EXECUTADO!"
    echo "============================================================================="
    echo -e "${NC}"
    echo -e "${GREEN} Comandos de deleção foram enviados para o Azure.${NC}"
    echo -e "${GREEN} Recursos estão sendo removidos em background.${NC}"
    echo -e "${GREEN} Acompanhe o progresso no Portal Azure.${NC}"
    echo ""
    echo -e "${BLUE} Para recriar a infraestrutura:${NC}"
    echo "1. Execute: ./scripts/setup-azure-infrastructure.sh"
    echo "2. Execute: ./scripts/setup-service-principal.sh"
    echo "3. Configure os secrets no GitHub"
    echo "4. Execute o Terraform nos ambientes"
    echo ""
    echo -e "${YELLOW}  AGUARDE a deleção completa antes de recriar (verifique Portal Azure)${NC}"
    echo ""
}

# Executar função principal
main "$@"