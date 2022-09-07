output "name" {
  value = var.name
  depends_on = [null_resource.setup_gitops]
}

output "namespace" {
  value = var.namespace
  depends_on = [null_resource.setup_gitops]
}
