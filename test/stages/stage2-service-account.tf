module "gitops_service_account" {
  source = "./module"

  gitops_config = module.gitops.gitops_config
  git_credentials = module.gitops.git_credentials
  namespace = var.namespace
  name = "test-sa"
  rbac_rules = [{
    apiGroups = ["*"]
    resources = ["*"]
    verbs     = ["*"]
  }]
  sccs = ["anyuid","privileged"]
  server_name = module.gitops.server_name
}
