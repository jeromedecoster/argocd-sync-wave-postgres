locals {
  # https://www.terraform.io/language/expressions/references#filesystem-and-workspace-info
  # target the $PROJECT_DIR
  project_dir = abspath("${path.root}/../..")

  repository_name = format("%s-%s", var.project_name, var.app_name)

  # xxx.dkr.ecr.xxx.amazonaws.com/sync-wave-vote
  repository_url = data.aws_ecr_repository.repository.repository_url

  # https://developer.hashicorp.com/terraform/language/functions/trimsuffix
  repository_address = trimsuffix(local.repository_url, "/${local.repository_name}")

  version = jsondecode(data.local_file.package_json.content).version

  # https://developer.hashicorp.com/terraform/language/functions/substr
  short_sha = substr(data.git_repository.git.commit_hash, 0, 9)



  local_tags = [
    # app-name:version
    "${local.repository_name}:${local.version}"
  ]

  ecr_tags = [
    # repository-url/app-name:version
    "${local.repository_url}:${local.version}",
    # repository-url/app-name:short-sha
    "${local.repository_url}:${local.short_sha}",
    # repository-url/app-name:latest
    "${local.repository_url}"
  ]
}