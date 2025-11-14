# IAM Policy for Crossplane S3 Provider
resource "aws_iam_policy" "crossplane_s3" {
  name        = "${var.cluster_name}-crossplane-s3-policy"
  description = "IAM policy for Crossplane S3 provider"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:*"
        ]
        Resource = "*"
      }
    ]
  })

  tags = var.tags
}

# IAM Role for Crossplane S3 Provider (using IRSA)
resource "aws_iam_role" "crossplane_s3" {
  name = "${var.cluster_name}-crossplane-s3-role"

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
            "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub" = "system:serviceaccount:crossplane-system:provider-aws-s3-*"
          }
          StringEquals = {
            "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = var.tags
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "crossplane_s3" {
  policy_arn = aws_iam_policy.crossplane_s3.arn
  role       = aws_iam_role.crossplane_s3.name
}

# Output the role ARN for ProviderConfig
output "crossplane_s3_role_arn" {
  value       = aws_iam_role.crossplane_s3.arn
  description = "IAM role ARN for Crossplane S3 provider"
}

# IAM Policy for Crossplane Keyspaces Provider
resource "aws_iam_policy" "crossplane_keyspaces" {
  name        = "${var.cluster_name}-crossplane-keyspaces-policy"
  description = "IAM policy for Crossplane Keyspaces provider"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cassandra:*"
        ]
        Resource = "*"
      }
    ]
  })

  tags = var.tags
}

# IAM Role for Crossplane Keyspaces Provider (using IRSA)
resource "aws_iam_role" "crossplane_keyspaces" {
  name = "${var.cluster_name}-crossplane-keyspaces-role"

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
            "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub" = "system:serviceaccount:crossplane-system:provider-aws-keyspaces-*"
          }
          StringEquals = {
            "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = var.tags
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "crossplane_keyspaces" {
  policy_arn = aws_iam_policy.crossplane_keyspaces.arn
  role       = aws_iam_role.crossplane_keyspaces.name
}

# Output the role ARN for ProviderConfig
output "crossplane_keyspaces_role_arn" {
  value       = aws_iam_role.crossplane_keyspaces.arn
  description = "IAM role ARN for Crossplane Keyspaces provider"
}

# IAM Policy for Crossplane OpenSearch Provider
resource "aws_iam_policy" "crossplane_opensearch" {
  name        = "${var.cluster_name}-crossplane-opensearch-policy"
  description = "IAM policy for Crossplane OpenSearch provider"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "es:*"
        ]
        Resource = "*"
      }
    ]
  })

  tags = var.tags
}

# IAM Role for Crossplane OpenSearch Provider (using IRSA)
resource "aws_iam_role" "crossplane_opensearch" {
  name = "${var.cluster_name}-crossplane-opensearch-role"

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
            "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub" = "system:serviceaccount:crossplane-system:provider-aws-opensearch-*"
          }
          StringEquals = {
            "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = var.tags
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "crossplane_opensearch" {
  policy_arn = aws_iam_policy.crossplane_opensearch.arn
  role       = aws_iam_role.crossplane_opensearch.name
}

# Output the role ARN for ProviderConfig
output "crossplane_opensearch_role_arn" {
  value       = aws_iam_role.crossplane_opensearch.arn
  description = "IAM role ARN for Crossplane OpenSearch provider"
}

# IAM Policy for Crossplane OpenSearch Serverless Provider
resource "aws_iam_policy" "crossplane_opensearchserverless" {
  name        = "${var.cluster_name}-crossplane-opensearchserverless-policy"
  description = "IAM policy for Crossplane OpenSearch Serverless provider"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "aoss:*"
        ]
        Resource = "*"
      }
    ]
  })

  tags = var.tags
}

# IAM Role for Crossplane OpenSearch Serverless Provider (using IRSA)
resource "aws_iam_role" "crossplane_opensearchserverless" {
  name = "${var.cluster_name}-crossplane-opensearchserverless-role"

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
            "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub" = "system:serviceaccount:crossplane-system:provider-aws-opensearchserverless-*"
          }
          StringEquals = {
            "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = var.tags
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "crossplane_opensearchserverless" {
  policy_arn = aws_iam_policy.crossplane_opensearchserverless.arn
  role       = aws_iam_role.crossplane_opensearchserverless.name
}

# Output the role ARN for ProviderConfig
output "crossplane_opensearchserverless_role_arn" {
  value       = aws_iam_role.crossplane_opensearchserverless.arn
  description = "IAM role ARN for Crossplane OpenSearch Serverless provider"
}

# IAM Policy for Crossplane IAM Provider
resource "aws_iam_policy" "crossplane_iam" {
  name        = "${var.cluster_name}-crossplane-iam-policy"
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

  tags = var.tags
}

# IAM Role for Crossplane IAM Provider (using IRSA)
resource "aws_iam_role" "crossplane_iam" {
  name = "${var.cluster_name}-crossplane-iam-role"

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

  tags = var.tags
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
