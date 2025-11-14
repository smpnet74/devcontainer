# EKS Fargate Cluster - Terraform Configuration

This Terraform configuration deploys an Amazon EKS cluster with Fargate support in the `us-east-2` region.

## Architecture

- **Region**: us-east-2
- **VPC**: New VPC with 10.0.0.0/16 CIDR
- **Subnets**: 3 public subnets across 3 availability zones (us-east-2a, us-east-2b, us-east-2c)
- **Compute**: Fargate only (no EC2 node groups)
- **Fargate Profiles**:
  - `kube-system` namespace - for Kubernetes system components
  - `default` namespace - for application workloads

## Security

- **API Access**: Restricted to specific IP addresses only:
  - 24.14.211.46/32
  - 3.86.241.195/32
- **Security Groups**: No overly permissive rules
- **Networking**: Public subnets with Internet Gateway

## Prerequisites

- Terraform >= 1.0
- AWS CLI configured with appropriate credentials
- kubectl (for cluster access after deployment)

## Deployment

1. **Initialize Terraform**:
   ```bash
   terraform init
   ```

2. **Review the plan**:
   ```bash
   terraform plan
   ```

3. **Apply the configuration**:
   ```bash
   terraform apply
   ```

4. **Configure kubectl**:
   ```bash
   aws eks update-kubeconfig --region us-east-2 --name fargate-eks-cluster
   ```

## Accessing the Cluster

After deployment, configure kubectl using the command from outputs:

```bash
terraform output kubectl_config_command
```

Then verify access:

```bash
kubectl get nodes
kubectl get pods -A
```

## Configuration Files

- `main.tf` - VPC, subnets, and networking
- `eks.tf` - EKS cluster, Fargate profiles, and IAM roles
- `variables.tf` - Input variables
- `terraform.tfvars` - Variable values
- `outputs.tf` - Output values

## Customization

Edit `terraform.tfvars` to customize:
- Cluster name
- Kubernetes version
- VPC CIDR range
- API access IPs
- Tags

## Adding More Fargate Profiles

To add additional namespaces for Fargate, add a new profile in `eks.tf`:

```hcl
resource "aws_eks_fargate_profile" "custom" {
  cluster_name           = aws_eks_cluster.main.name
  fargate_profile_name   = "custom-namespace"
  pod_execution_role_arn = aws_iam_role.fargate_pod_execution.arn
  subnet_ids             = aws_subnet.public[*].id

  selector {
    namespace = "your-namespace"
  }

  tags = var.tags
}
```

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

## Notes

- This configuration uses public subnets for simplicity and cost savings
- For production with managed node groups, consider adding private subnets with NAT gateways
- Fargate profiles are created for kube-system and default namespaces
- CoreDNS will automatically run on Fargate in the kube-system namespace
