output "cluster_id" {
  description = "EKS cluster ID"
  value       = aws_eks_cluster.main.id
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = aws_security_group.eks_cluster.id
}

output "cluster_arn" {
  description = "ARN of the EKS cluster"
  value       = aws_eks_cluster.main.arn
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = aws_eks_cluster.main.certificate_authority[0].data
  sensitive   = true
}

output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.main.name
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "fargate_profile_system_arn" {
  description = "ARN of the system Fargate profile"
  value       = aws_eks_fargate_profile.system.arn
}

output "fargate_profile_applications1_arn" {
  description = "ARN of the applications1 Fargate profile"
  value       = aws_eks_fargate_profile.applications1.arn
}

output "configure_kubectl" {
  description = "Run this command to configure kubectl access to the cluster"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.main.name}"
}

output "kubectl_test_command" {
  description = "Run this command after configuring kubectl to verify cluster access"
  value       = "kubectl get nodes && kubectl get pods -A"
}

output "cluster_info" {
  description = "Quick reference for cluster information"
  value = {
    cluster_name = aws_eks_cluster.main.name
    region       = var.aws_region
    endpoint     = aws_eks_cluster.main.endpoint
    version      = aws_eks_cluster.main.version
  }
}
