################################################################################
# GitHub Data Source & OIDC Provider
################################################################################

# GitHub's OIDC Provider TLS Certificate Thumbprint
# Standard root thumbprint for token.actions.githubusercontent.com
data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
}

# Create the OIDC Provider in AWS IAM
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github.certificates[0].sha1_fingerprint]

  tags = {
    Environment = "development"
    ManagedBy   = "Terraform"
  }
}

################################################################################
# IAM Role & Trust Policy for GitHub Actions
################################################################################

# Local variables to configure repository constraints easily
locals {
  github_username_or_org = "abdulsalamkp2003" # e.g., "abdul-repo"
  github_repo_name       = "devops_cicd"        # e.g., "learn-terraform-get-started-aws"
}

# Create the IAM Role that GitHub Actions will assume
resource "aws_iam_role" "github_actions" {
  name = "GitHubActions-Terraform-Role"

  # Trust policy restricting access strictly to your repository
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            # Limits role assumption to your specific GitHub repo across all branches and events
            "token.actions.githubusercontent.com:sub" = "repo:${local.github_username_or_org}/${local.github_repo_name}:*"
          }
        }
      }
    ]
  })

  tags = {
    Environment = "development"
    ManagedBy   = "Terraform"
  }
}

################################################################################
# Attach Permissions to the Role
################################################################################

# Attach AdministratorAccess (or custom policies) to allow Terraform to manage resources
resource "aws_iam_role_policy_attachment" "github_actions_admin" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

################################################################################
# Output the Role ARN
################################################################################

output "github_actions_role_arn" {
  description = "ARN of the IAM Role for GitHub Actions OIDC"
  value       = aws_iam_role.github_actions.arn
}