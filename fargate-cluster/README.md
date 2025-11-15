# Fargate EKS Cluster - Two-Layer Terraform Configuration

This project uses a two-layer Terraform approach to manage EKS infrastructure, solving destroy race conditions and providing better control over infrastructure lifecycle.

## Architecture

```
fargate-cluster/
├── infra/          # Layer 1: Base Infrastructure
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── iam.tf
│   └── security-groups.tf
└── eks/            # Layer 2: EKS & Kubernetes Resources
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    ├── cluster.tf
    ├── oidc.tf
    ├── crossplane-irsa.tf
    ├── argocd.tf
    └── addons.tf
```

## Layer 1: Infrastructure (`infra/`)

Contains base AWS infrastructure:
- VPC with public and private subnets
- Internet Gateway and NAT Gateway
- Route tables
- Security groups (EKS cluster, ArgoCD LoadBalancer)
- IAM roles (EKS cluster role, Fargate pod execution role)

## Layer 2: EKS (`eks/`)

Contains EKS and Kubernetes resources:
- EKS cluster
- Fargate profiles
- OIDC provider for IRSA
- Crossplane IAM roles
- EKS Blueprints Addons (AWS Load Balancer Controller, ArgoCD)
- ArgoCD ConfigMap customizations

The EKS layer reads outputs from the infra layer via `terraform_remote_state`.

## Deployment

### Initial Deployment

```bash
# 1. Deploy infrastructure layer
cd infra
terraform init
terraform plan
terraform apply

# 2. Deploy EKS layer
cd ../eks
terraform init
terraform plan
terraform apply

# 3. Configure kubectl
aws eks update-kubeconfig --region us-east-2 --name fargate-eks-cluster
kubectl get nodes
```

### Destruction

**IMPORTANT:** Destroy in reverse order to avoid race conditions.

```bash
# 1. Destroy EKS layer first
cd eks
terraform destroy

# 2. Destroy infrastructure layer
cd ../infra
terraform destroy
```

## Configuration

### Variables

**infra/variables.tf:**
- `aws_region` - AWS region (default: us-east-2)
- `cluster_name` - EKS cluster name (default: fargate-eks-cluster)
- `vpc_cidr` - VPC CIDR block (default: 10.0.0.0/16)
- `tags` - Common tags for all resources

**eks/variables.tf:**
- `aws_region` - AWS region (default: us-east-2)
- `kubernetes_version` - Kubernetes version (default: 1.34)
- `api_access_cidrs` - CIDRs allowed to access API server
- `infra_state_path` - Path to infra state file (default: ../infra/terraform.tfstate)

### Customizing

To customize the configuration:

1. Edit `infra/terraform.tfvars` for infrastructure settings
2. Edit `eks/terraform.tfvars` for EKS settings
3. Modify Fargate profiles in `eks/cluster.tf`
4. Add/remove Crossplane providers in `eks/crossplane-irsa.tf`
5. Customize ArgoCD in `eks/argocd.tf` and `eks/addons.tf`

## Remote State

Currently using **local** backend for state storage. For production, consider using remote backend:

```hcl
# In both infra/main.tf and eks/main.tf
terraform {
  backend "s3" {
    bucket = "your-terraform-state-bucket"
    key    = "fargate-cluster/infra/terraform.tfstate"  # or eks/terraform.tfstate
    region = "us-east-2"
  }
}
```

Then update `eks/variables.tf`:

```hcl
variable "infra_state_path" {
  # Not needed when using remote backend
}
```

And update `eks/main.tf`:

```hcl
data "terraform_remote_state" "infra" {
  backend = "s3"

  config = {
    bucket = "your-terraform-state-bucket"
    key    = "fargate-cluster/infra/terraform.tfstate"
    region = "us-east-2"
  }
}
```

## Benefits of This Approach

1. **Controlled Destruction Order** - EKS resources are destroyed before infrastructure
2. **Faster Iterations** - Modify EKS without touching base infrastructure
3. **Clear Dependencies** - Explicit data flow between layers via remote state
4. **Reduced Blast Radius** - Less risk of accidentally destroying base infrastructure
5. **No More Race Conditions** - LoadBalancers and ENIs cleaned up before VPC destruction

## Troubleshooting

### EKS layer can't find infra state

Ensure `infra_state_path` points to the correct location:

```bash
cd eks
terraform console
> data.terraform_remote_state.infra.outputs.vpc_id
```

### Fargate pods not scheduling

Check CoreDNS has Fargate tolerations:

```bash
kubectl get deployment coredns -n kube-system -o yaml | grep -A 5 tolerations
```

### Destroy fails with dependencies

Always destroy EKS layer first, then infrastructure layer. If destroy hangs, check for:
- Lingering LoadBalancers: `aws elbv2 describe-load-balancers`
- Stuck ENIs: `aws ec2 describe-network-interfaces --filters Name=vpc-id,Values=<vpc-id>`

## Next Steps

- Configure Crossplane providers
- Deploy applications via ArgoCD
- Set up monitoring and logging
- Configure IRSA for additional workloads
