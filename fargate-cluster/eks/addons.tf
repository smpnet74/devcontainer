# EKS Blueprints Addons - AWS Load Balancer Controller
module "eks_blueprints_addons_lbc" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.19"

  cluster_name      = aws_eks_cluster.main.name
  cluster_endpoint  = aws_eks_cluster.main.endpoint
  cluster_version   = aws_eks_cluster.main.version
  oidc_provider_arn = aws_iam_openid_connect_provider.eks.arn

  enable_aws_load_balancer_controller = true

  aws_load_balancer_controller = {
    chart_version = "1.14.1"

    set = [
      {
        name  = "vpcId"
        value = local.vpc_id
      },
      {
        name  = "tolerations[0].key"
        value = "eks.amazonaws.com/compute-type"
      },
      {
        name  = "tolerations[0].operator"
        value = "Equal"
      },
      {
        name  = "tolerations[0].value"
        value = "fargate"
      },
      {
        name  = "tolerations[0].effect"
        value = "NoSchedule"
      }
    ]
  }

  tags = local.tags
}

# EKS Blueprints Addons - ArgoCD
module "eks_blueprints_addons_argocd" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.19"

  cluster_name      = aws_eks_cluster.main.name
  cluster_endpoint  = aws_eks_cluster.main.endpoint
  cluster_version   = aws_eks_cluster.main.version
  oidc_provider_arn = aws_iam_openid_connect_provider.eks.arn

  enable_argocd = true

  argocd = {
    namespace        = "argocd"
    create_namespace = true
    chart_version    = "9.1.0"

    set = [
      {
        name  = "server.service.type"
        value = "LoadBalancer"
      },
      {
        name  = "server.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
        value = "external"
      },
      {
        name  = "server.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-nlb-target-type"
        value = "ip"
      },
      {
        name  = "server.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-scheme"
        value = "internet-facing"
      },
      {
        name  = "server.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-security-groups"
        value = local.argocd_lb_sg_id
      },
      {
        name  = "configs.params.server\\.insecure"
        value = "true"
      },
      {
        name  = "metrics.enabled"
        value = "true"
      },
      {
        name  = "controller.tolerations[0].key"
        value = "eks.amazonaws.com/compute-type"
      },
      {
        name  = "controller.tolerations[0].operator"
        value = "Equal"
      },
      {
        name  = "controller.tolerations[0].value"
        value = "fargate"
      },
      {
        name  = "controller.tolerations[0].effect"
        value = "NoSchedule"
      },
      {
        name  = "server.tolerations[0].key"
        value = "eks.amazonaws.com/compute-type"
      },
      {
        name  = "server.tolerations[0].operator"
        value = "Equal"
      },
      {
        name  = "server.tolerations[0].value"
        value = "fargate"
      },
      {
        name  = "server.tolerations[0].effect"
        value = "NoSchedule"
      },
      {
        name  = "repoServer.tolerations[0].key"
        value = "eks.amazonaws.com/compute-type"
      },
      {
        name  = "repoServer.tolerations[0].operator"
        value = "Equal"
      },
      {
        name  = "repoServer.tolerations[0].value"
        value = "fargate"
      },
      {
        name  = "repoServer.tolerations[0].effect"
        value = "NoSchedule"
      },
      {
        name  = "applicationSet.tolerations[0].key"
        value = "eks.amazonaws.com/compute-type"
      },
      {
        name  = "applicationSet.tolerations[0].operator"
        value = "Equal"
      },
      {
        name  = "applicationSet.tolerations[0].value"
        value = "fargate"
      },
      {
        name  = "applicationSet.tolerations[0].effect"
        value = "NoSchedule"
      },
      {
        name  = "notifications.tolerations[0].key"
        value = "eks.amazonaws.com/compute-type"
      },
      {
        name  = "notifications.tolerations[0].operator"
        value = "Equal"
      },
      {
        name  = "notifications.tolerations[0].value"
        value = "fargate"
      },
      {
        name  = "notifications.tolerations[0].effect"
        value = "NoSchedule"
      },
      {
        name  = "redis.tolerations[0].key"
        value = "eks.amazonaws.com/compute-type"
      },
      {
        name  = "redis.tolerations[0].operator"
        value = "Equal"
      },
      {
        name  = "redis.tolerations[0].value"
        value = "fargate"
      },
      {
        name  = "redis.tolerations[0].effect"
        value = "NoSchedule"
      },
      {
        name  = "dex.tolerations[0].key"
        value = "eks.amazonaws.com/compute-type"
      },
      {
        name  = "dex.tolerations[0].operator"
        value = "Equal"
      },
      {
        name  = "dex.tolerations[0].value"
        value = "fargate"
      },
      {
        name  = "dex.tolerations[0].effect"
        value = "NoSchedule"
      }
    ]
  }

  tags = local.tags
}
