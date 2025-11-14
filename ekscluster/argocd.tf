# Security Group for ArgoCD LoadBalancer
# This security group is referenced by the ArgoCD LoadBalancer service annotation
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

# Note: ArgoCD is now installed via the EKS Blueprints Addons module
# See aws-blueprints-addons.tf for the ArgoCD installation configuration

# ArgoCD ConfigMap for Crossplane compatibility
resource "kubernetes_config_map_v1_data" "argocd_cm_crossplane" {
  metadata {
    name      = "argocd-cm"
    namespace = "argocd"
  }

  data = {
    # Use annotation-based resource tracking (required for Crossplane)
    "application.resourceTrackingMethod" = "annotation"

    # Exclude ProviderConfigUsage resources to improve UI performance
    "resource.exclusions" = <<-EOT
      - apiGroups:
        - "*"
        kinds:
        - ProviderConfigUsage
    EOT

    # Custom health checks for Crossplane resources
    "resource.customizations.health.apiextensions.crossplane.io_CompositeResourceDefinition" = <<-EOT
      hs = {}
      hs.status = "Healthy"
      hs.message = "Resource is always healthy"
      return hs
    EOT

    "resource.customizations.health.pkg.crossplane.io_Provider" = <<-EOT
      hs = {}
      if obj.status ~= nil then
        if obj.status.conditions ~= nil then
          for i, condition in ipairs(obj.status.conditions) do
            if condition.type == "Healthy" and condition.status == "True" then
              hs.status = "Healthy"
              hs.message = "Provider is healthy"
              return hs
            end
            if condition.type == "Healthy" and condition.status == "False" then
              hs.status = "Degraded"
              hs.message = condition.message
              return hs
            end
          end
        end
      end
      hs.status = "Progressing"
      hs.message = "Waiting for provider to become healthy"
      return hs
    EOT

    "resource.customizations.health.pkg.crossplane.io_ProviderRevision" = <<-EOT
      hs = {}
      if obj.status ~= nil then
        if obj.status.conditions ~= nil then
          for i, condition in ipairs(obj.status.conditions) do
            if condition.type == "Healthy" and condition.status == "True" then
              hs.status = "Healthy"
              hs.message = "ProviderRevision is healthy"
              return hs
            end
            if condition.type == "Healthy" and condition.status == "False" then
              hs.status = "Degraded"
              hs.message = condition.message
              return hs
            end
          end
        end
      end
      hs.status = "Progressing"
      hs.message = "Waiting for provider revision to become healthy"
      return hs
    EOT
  }

  force = true

  depends_on = [
    module.eks_blueprints_addons_argocd
  ]
}

# Note: To set ARGOCD_K8S_CLIENT_QPS=300 for better Crossplane CRD handling, run:
# kubectl set env statefulset/argocd-application-controller -n argocd ARGOCD_K8S_CLIENT_QPS=300

