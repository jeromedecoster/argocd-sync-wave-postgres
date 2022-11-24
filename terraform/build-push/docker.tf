# https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/image
resource "docker_image" "image" {
  name = var.app_name

  build {
    path = "${local.project_dir}/${var.app_name}"

    tag = [
      # app-name:version
      "${local.repository_name}:${local.version}",
      # # repository-url/app-name:version
      # "${local.repository_url}:${local.version}",
      # # repository-url/app-name:short-sha
      # "${local.repository_url}:${local.short_sha}",
      # # repository-url/app-name:latest
      # "${local.repository_url}"
    ]
  }
}

# https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/tag
resource "docker_tag" "tag" {
  source_image = "${local.repository_name}:${local.version}"
  for_each     = toset(local.ecr_tags)
  target_image = each.value
}

# https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/registry_image
resource "docker_registry_image" "registry_image" {
  for_each = toset(local.ecr_tags)
  name     = each.value
}
