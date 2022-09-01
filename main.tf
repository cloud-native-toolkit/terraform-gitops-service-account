locals {
  bin_dir  = module.setup_clis.bin_dir
  layer = "infrastructure"
  yaml_dir = "${path.cwd}/.tmp/sa-${var.name}/namespace/${var.namespace}"
  name = "${var.name}-sa"
  pull_secret_values = [for s in var.pull_secrets: {name = s}]
  type = "base"
  ignore_diff = [{
    kind = "ServiceAccount"
    jsonPointers = [
      "/imagePullSecrets",
      "/secrets"
    ]
  }]
}

module setup_clis {
  source = "github.com/cloud-native-toolkit/terraform-util-clis.git"
}

resource null_resource create_yaml {
  provisioner "local-exec" {
    command = "${path.module}/scripts/create-yaml.sh '${local.yaml_dir}' '${var.name}' '${jsonencode(local.pull_secret_values)}'"

    environment = {
      BIN_DIR = module.setup_clis.bin_dir
    }
  }
}

resource gitops_module module {
  depends_on = [null_resource.create_yaml]

  name = local.name
  namespace = var.namespace
  content_dir = local.yaml_dir
  server_name = var.server_name
  layer = local.layer
  type = local.type
  config = yamlencode(var.gitops_config)
  credentials = yamlencode(var.git_credentials)
}

module "rbac" {
  source = "github.com/cloud-native-toolkit/terraform-gitops-rbac.git?ref=v1.9.1"
  depends_on = [gitops_module.module]

  gitops_config             = var.gitops_config
  git_credentials           = var.git_credentials
  service_account_namespace = var.namespace
  service_account_name      = var.name
  namespace                 = var.namespace
  rules                     = var.rbac_rules
  server_name               = var.server_name
  cluster_scope             = var.rbac_cluster_scope
  roles                     = var.rbac_roles
}

module "sccs" {
  source = "github.com/cloud-native-toolkit/terraform-gitops-sccs.git?ref=v1.4.1"
  depends_on = [gitops_module.module]

  gitops_config = var.gitops_config
  git_credentials = var.git_credentials
  namespace = var.namespace
  service_account = var.name
  sccs = var.sccs
  server_name = var.server_name
}
