output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "eks_cluster_sg_id" {
  description = "Security group ID for EKS cluster"
  value       = aws_security_group.eks_cluster.id
}

output "argocd_lb_sg_id" {
  description = "Security group ID for ArgoCD LoadBalancer"
  value       = aws_security_group.argocd_lb.id
}

output "eks_cluster_role_arn" {
  description = "ARN of the EKS cluster IAM role"
  value       = aws_iam_role.eks_cluster.arn
}

output "fargate_pod_execution_role_arn" {
  description = "ARN of the Fargate pod execution IAM role"
  value       = aws_iam_role.fargate_pod_execution.arn
}

output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = var.cluster_name
}

output "aws_region" {
  description = "AWS region"
  value       = var.aws_region
}

output "tags" {
  description = "Common tags"
  value       = var.tags
}
