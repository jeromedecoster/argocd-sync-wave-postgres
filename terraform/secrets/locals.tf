locals {
  # https://www.terraform.io/language/expressions/references#filesystem-and-workspace-info
  # target the $PROJECT_DIR
  project_dir = abspath("${path.root}/../..")

  key_file_pem = "${local.project_dir}/${var.project_name}.pem"

  registry_server = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com"

  kubectl_vars = {
    ssh_private_key     = base64encode(data.local_file.key_file_pem.content)
    auth_token_password = base64encode("AWS:${data.aws_ecr_authorization_token.auth_token.password}")
    docker_config_json = base64encode(jsonencode({
      auths = {
        "${local.registry_server}" = {
          "username" = "AWS"
          "password" = data.aws_ecr_authorization_token.auth_token.password
          "auth"     = base64encode("AWS:${data.aws_ecr_authorization_token.auth_token.password}")
        }
      }
    }))
  }
}