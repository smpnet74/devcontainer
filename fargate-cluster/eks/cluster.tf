# EKS Cluster
resource "aws_eks_cluster" "main" {
  name     = local.cluster_name
  role_arn = local.eks_cluster_role_arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = concat(local.public_subnet_ids, local.private_subnet_ids)
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = var.api_access_cidrs
    security_group_ids      = [local.eks_cluster_sg_id]
  }

  tags = local.tags
}

# Security group rule to allow NLB to reach Fargate pods
resource "aws_security_group_rule" "allow_nlb_to_pods" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = [local.vpc_cidr]
  description       = "Allow NLB traffic to reach Fargate pods"
  security_group_id = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
}

# Fargate Profile - wildcard to match all namespaces
resource "aws_eks_fargate_profile" "all_namespaces" {
  cluster_name           = aws_eks_cluster.main.name
  fargate_profile_name   = "all-namespaces"
  pod_execution_role_arn = local.fargate_pod_execution_role_arn
  subnet_ids             = local.private_subnet_ids

  selector {
    namespace = "*"
  }

  tags = local.tags
}


# Patch CoreDNS to run on Fargate
resource "null_resource" "patch_coredns" {
  provisioner "local-exec" {
    command = <<-EOT
      aws eks update-kubeconfig --name ${aws_eks_cluster.main.name} --region ${var.aws_region}
      kubectl patch deployment coredns -n kube-system --type=strategic --patch='
spec:
  template:
    spec:
      tolerations:
      - key: eks.amazonaws.com/compute-type
        operator: Equal
        value: fargate
        effect: NoSchedule
'
    EOT
  }

  triggers = {
    cluster_id = aws_eks_cluster.main.id
  }
}
