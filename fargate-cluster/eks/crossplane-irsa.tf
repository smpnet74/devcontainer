# IAM Policy for Crossplane IAM Provider
resource "aws_iam_policy" "crossplane_iam" {
  name        = "${local.cluster_name}-crossplane-iam-policy"
  description = "IAM policy for Crossplane IAM provider"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "iam:*"
        ]
        Resource = "*"
      }
    ]
  })

  tags = local.tags
}

# IAM Role for Crossplane IAM Provider (using IRSA)
resource "aws_iam_role" "crossplane_iam" {
  name = "${local.cluster_name}-crossplane-iam-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.eks.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringLike = {
            "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub" = "system:serviceaccount:crossplane-system:provider-aws-iam-*"
          }
          StringEquals = {
            "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = local.tags
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "crossplane_iam" {
  policy_arn = aws_iam_policy.crossplane_iam.arn
  role       = aws_iam_role.crossplane_iam.name
}

# Output the role ARN for ProviderConfig
output "crossplane_iam_role_arn" {
  value       = aws_iam_role.crossplane_iam.arn
  description = "IAM role ARN for Crossplane IAM provider"
}
