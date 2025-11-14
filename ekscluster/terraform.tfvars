# AWS Configuration
aws_region = "us-east-2"

# EKS Cluster Configuration
cluster_name       = "fargate-eks-cluster"
kubernetes_version = "1.34"

# Network Configuration
vpc_cidr = "10.0.0.0/16"

# API Access - Restrict to specific IPs only
api_access_cidrs = [
  "24.14.211.46/32",
  "3.85.241.195/32"
]

# Tags
tags = {
  Terraform   = "true"
  Environment = "production"
  ManagedBy   = "terraform"
  Project     = "eks-fargate"
}
