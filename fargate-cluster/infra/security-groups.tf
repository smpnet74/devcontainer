# EKS Cluster Security Group
resource "aws_security_group" "eks_cluster" {
  name        = "${var.cluster_name}-cluster-sg"
  description = "Security group for EKS cluster control plane"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-cluster-sg"
    }
  )
}

# Security Group for ArgoCD LoadBalancer
resource "aws_security_group" "argocd_lb" {
  name        = "${var.cluster_name}-argocd-lb-sg"
  description = "Security group for ArgoCD LoadBalancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from authorized IP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["24.14.211.46/32"]
  }

  ingress {
    description = "HTTPS from authorized IP"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["24.14.211.46/32"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-argocd-lb-sg"
    }
  )
}
