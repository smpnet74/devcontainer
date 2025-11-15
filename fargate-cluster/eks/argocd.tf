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
}
