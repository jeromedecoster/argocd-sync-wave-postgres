resource "null_resource" "env-file" {

  triggers = {
    # everytime = uuid()
    rarely = join("-", [
      local.kind_listen_address,
      local.kind_localhost_port,
      kind_cluster.cluster.endpoint
    ])
  }

  provisioner "local-exec" {
    command = "scripts/env-file.sh .env KIND_LISTEN_ADDRESS KIND_LOCALHOST_PORT"

    working_dir = local.project_dir

    environment = {
      KIND_LISTEN_ADDRESS = local.kind_listen_address
      KIND_LOCALHOST_PORT = local.kind_localhost_port
    }
  }

  depends_on = [
    kind_cluster.cluster
  ]
}