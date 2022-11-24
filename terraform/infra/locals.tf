locals {
  # https://www.terraform.io/language/expressions/references#filesystem-and-workspace-info
  # target the $PROJECT_DIR
  project_dir = abspath("${path.root}/../..")

  repository_name = format("%s-%s", var.project_name, var.app_name)

  key_file_pub = "${local.project_dir}/${var.project_name}.pub"
  key_file_pem = "${local.project_dir}/${var.project_name}.pem"
}