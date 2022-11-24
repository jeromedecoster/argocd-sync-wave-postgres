# https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file
data "local_file" "package_json" {
  filename = "${local.project_dir}/${var.app_name}/package.json"
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecr_authorization_token
data "aws_ecr_authorization_token" "token" {}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecr_repository
data "aws_ecr_repository" "repository" {
  name = local.repository_name
}

# https://registry.terraform.io/providers/paultyng/git/latest/docs/data-sources/repository
data "git_repository" "git" {
  path = local.project_dir
}
