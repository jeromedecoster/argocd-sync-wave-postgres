# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecr_repository
data "aws_ecr_repository" "repository" {
  name = local.repository_name
}