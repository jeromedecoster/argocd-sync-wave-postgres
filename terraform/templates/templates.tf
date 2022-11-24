resource "local_file" "template_argocd" {
  for_each = fileset("${local.project_dir}/argocd/.tmpl/", "**")
  content  = templatefile("${local.project_dir}/argocd/.tmpl/${each.value}", local.template_vars)
  filename = pathexpand("${local.project_dir}/argocd/${each.value}")
}

resource "local_file" "template_no_sync" {
  for_each = fileset("${local.project_dir}/manifests/no-sync/.tmpl/", "**")
  content  = templatefile("${local.project_dir}/manifests/no-sync/.tmpl/${each.value}", local.template_vars)
  filename = pathexpand("${local.project_dir}/manifests/no-sync/${each.value}")
}

resource "local_file" "template_sync" {
  for_each = fileset("${local.project_dir}/manifests/sync/.tmpl/", "**")
  content  = templatefile("${local.project_dir}/manifests/sync/.tmpl/${each.value}", local.template_vars)
  filename = pathexpand("${local.project_dir}/manifests/sync/${each.value}")
}