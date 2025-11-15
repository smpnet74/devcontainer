variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-2"
}

variable "kubernetes_version" {
  description = "Kubernetes version to use for the EKS cluster"
  type        = string
  default     = "1.34"
}

variable "api_access_cidrs" {
  description = "List of CIDR blocks that can access the Kubernetes API server"
  type        = list(string)
  default     = ["24.14.211.46/32", "3.85.241.195/32"]
}

variable "infra_state_path" {
  description = "Path to the infra layer terraform.tfstate file"
  type        = string
  default     = "../infra/terraform.tfstate"
}
