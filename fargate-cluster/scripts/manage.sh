#!/bin/bash

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
INFRA_DIR="$PROJECT_ROOT/infra"
EKS_DIR="$PROJECT_ROOT/eks"

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Function to display usage
usage() {
    echo "Usage: $0 {create|destroy}"
    echo ""
    echo "Commands:"
    echo "  create   - Deploy infrastructure layer first, then EKS layer"
    echo "  destroy  - Destroy EKS layer first, then infrastructure layer"
    echo ""
    echo "Examples:"
    echo "  $0 create    # Deploy the complete stack"
    echo "  $0 destroy   # Destroy the complete stack"
    exit 1
}

# Function to check if directory exists
check_directory() {
    if [ ! -d "$1" ]; then
        print_error "Directory not found: $1"
        exit 1
    fi
}

# Function to check prerequisites
check_prerequisites() {
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform is not installed. Please install Terraform first."
        exit 1
    fi

    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI is not installed. Please install AWS CLI first."
        exit 1
    fi

    print_info "Prerequisites check passed."
}

# Function to deploy a layer
deploy_layer() {
    local layer_name=$1
    local layer_dir=$2

    print_info "========================================"
    print_info "Deploying ${layer_name} layer..."
    print_info "========================================"
    cd "$layer_dir"

    print_info "Initializing Terraform..."
    terraform init

    print_info "Validating configuration..."
    terraform validate

    print_info "Planning deployment..."
    terraform plan -out=tfplan

    print_info "Applying deployment..."
    terraform apply tfplan

    rm -f tfplan

    print_success "${layer_name} layer deployed successfully!"
    echo ""
}

# Function to destroy a layer
destroy_layer() {
    local layer_name=$1
    local layer_dir=$2

    print_info "========================================"
    print_info "Destroying ${layer_name} layer..."
    print_info "========================================"
    cd "$layer_dir"

    print_info "Destroying ${layer_name} layer..."
    terraform destroy -auto-approve

    print_success "${layer_name} layer destroyed successfully!"
    echo ""
}

# Function to destroy ArgoCD installation
destroy_argocd() {
    local layer_dir=$1

    print_info "========================================"
    print_info "Destroying ArgoCD installation..."
    print_info "========================================"
    cd "$layer_dir"

    print_info "Targeting ArgoCD module for destruction..."
    terraform destroy -target=module.eks_blueprints_addons_argocd -auto-approve

    print_info "Targeting ArgoCD ConfigMap for destruction..."
    terraform destroy -target=kubernetes_config_map_v1_data.argocd_cm_crossplane -auto-approve

    print_success "ArgoCD installation destroyed successfully!"
    echo ""
}

# Main script logic
main() {
    if [ $# -eq 0 ]; then
        print_error "No command specified."
        usage
    fi

    check_prerequisites
    check_directory "$INFRA_DIR"
    check_directory "$EKS_DIR"

    case "$1" in
        create)
            print_success "===================================================="
            print_success "Starting Full Stack Deployment"
            print_success "===================================================="
            echo ""

            # Deploy infrastructure first
            deploy_layer "Infrastructure" "$INFRA_DIR"

            # Deploy EKS second
            deploy_layer "EKS" "$EKS_DIR"

            print_success "===================================================="
            print_success "Full Stack Deployment Complete!"
            print_success "===================================================="
            echo ""
            print_info "To configure kubectl, run:"
            cd "$EKS_DIR"
            CLUSTER_NAME=$(terraform output -raw cluster_name 2>/dev/null || echo "fargate-eks-cluster")
            AWS_REGION=$(terraform output -raw configure_kubectl 2>/dev/null | grep -oP 'region \K[^ ]+' || echo "us-east-2")
            echo -e "${GREEN}  aws eks update-kubeconfig --region ${AWS_REGION} --name ${CLUSTER_NAME}${NC}"
            echo ""
            print_info "To verify cluster access:"
            echo -e "${GREEN}  kubectl get nodes${NC}"
            echo -e "${GREEN}  kubectl get pods -A${NC}"
            ;;

        destroy)
            print_warning "===================================================="
            print_warning "Starting Full Stack Destruction"
            print_warning "===================================================="
            echo ""
            print_warning "This will destroy ALL resources in the correct order:"
            print_warning "  1. ArgoCD installation"
            print_warning "  2. EKS layer (cluster, Fargate, addons)"
            print_warning "  3. Infrastructure layer (VPC, networking, IAM)"
            echo ""

            read -p "Are you sure you want to destroy the entire stack? (yes/no): " confirm
            if [ "$confirm" != "yes" ]; then
                print_info "Destruction cancelled."
                exit 0
            fi

            # Destroy ArgoCD first
            destroy_argocd "$EKS_DIR"

            # Destroy EKS second
            destroy_layer "EKS" "$EKS_DIR"

            # Destroy infrastructure third
            destroy_layer "Infrastructure" "$INFRA_DIR"

            print_success "===================================================="
            print_success "Full Stack Destruction Complete!"
            print_success "===================================================="
            ;;

        *)
            print_error "Invalid command: $1"
            usage
            ;;
    esac
}

# Run main function
main "$@"
