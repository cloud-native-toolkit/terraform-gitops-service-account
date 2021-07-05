output "name" {
  value = var.name
  depends_on = [null_resource.setup_argocd]
}

output "namespace" {
  value = var.namespace
  depends_on = [null_resource.setup_argocd]
}
