terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

# Read outputs from infra layer
data "terraform_remote_state" "infra" {
  backend = "local"

  config = {
    path = var.infra_state_path
  }
}

# Local values to simplify references
locals {
  cluster_name                  = data.terraform_remote_state.infra.outputs.cluster_name
  vpc_id                        = data.terraform_remote_state.infra.outputs.vpc_id
  vpc_cidr                      = data.terraform_remote_state.infra.outputs.vpc_cidr
  public_subnet_ids             = data.terraform_remote_state.infra.outputs.public_subnet_ids
  private_subnet_ids            = data.terraform_remote_state.infra.outputs.private_subnet_ids
  eks_cluster_sg_id             = data.terraform_remote_state.infra.outputs.eks_cluster_sg_id
  argocd_lb_sg_id               = data.terraform_remote_state.infra.outputs.argocd_lb_sg_id
  eks_cluster_role_arn          = data.terraform_remote_state.infra.outputs.eks_cluster_role_arn
  fargate_pod_execution_role_arn = data.terraform_remote_state.infra.outputs.fargate_pod_execution_role_arn
  tags                          = data.terraform_remote_state.infra.outputs.tags
}

provider "aws" {
  region = var.aws_region
}

provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.main.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.main.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args = [
        "eks",
        "get-token",
        "--cluster-name",
        aws_eks_cluster.main.name,
        "--region",
        var.aws_region
      ]
    }
  }
}

provider "kubernetes" {
  host                   = aws_eks_cluster.main.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.main.certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      aws_eks_cluster.main.name,
      "--region",
      var.aws_region
    ]
  }
}
