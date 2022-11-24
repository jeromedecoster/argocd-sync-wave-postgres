output "project_name" {
  value = var.project_name
}

output "app_name" {
  value = var.app_name
}

output "aws_region" {
  value = var.aws_region
}

output "github_owner" {
  value = var.github_owner
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository#repository_url
output "ecr_repository_url" {
  value = aws_ecr_repository.repository.repository_url
}
