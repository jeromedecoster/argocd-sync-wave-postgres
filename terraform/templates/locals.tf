locals {
  # https://www.terraform.io/language/expressions/references#filesystem-and-workspace-info
  # target the $PROJECT_DIR
  project_dir = abspath("${path.root}/../..")

  repository_name = format("%s-%s", var.project_name, var.app_name)

  # xxx.dkr.ecr.xxx.amazonaws.com/sync-wave-vote
  repository_url = data.aws_ecr_repository.repository.repository_url

  template_vars = {
    website_image = "${local.repository_url}:0.0.1"
    git_repo_url  = var.github_repo
  }
}