locals {
  bin_dir  = module.setup_clis.bin_dir
  layer = "infrastructure"
  yaml_dir = "${path.cwd}/.tmp/sa-${var.name}/namespace/${var.namespace}"
  name = "${var.name}-sa"
}

module setup_clis {
  source = "github.com/cloud-native-toolkit/terraform-util-clis.git"
}

resource null_resource create_yaml {
  provisioner "local-exec" {
    command = "${path.module}/scripts/create-yaml.sh '${local.yaml_dir}' '${var.name}' '${jsonencode(var.pull_secrets)}'"

    environment = {
      BIN_DIR = module.setup_clis.bin_dir
    }
  }
}

resource null_resource setup_gitops {
  depends_on = [null_resource.create_yaml]

  provisioner "local-exec" {
    command = "${local.bin_dir}/igc gitops-module '${local.name}' -n '${var.namespace}' --contentDir '${local.yaml_dir}' --serverName '${var.server_name}' -l '${local.layer}'"

    environment = {
      GIT_CREDENTIALS = nonsensitive(yamlencode(var.git_credentials))
      GITOPS_CONFIG   = yamlencode(var.gitops_config)
    }
  }
}

module "rbac" {
  source = "github.com/cloud-native-toolkit/terraform-gitops-rbac.git?ref=v1.6.2"
  depends_on = [null_resource.setup_gitops]

  gitops_config             = var.gitops_config
  git_credentials           = var.git_credentials
  service_account_namespace = var.namespace
  service_account_name      = var.name
  namespace                 = var.namespace
  rules                     = var.rbac_rules
  server_name               = var.server_name
}

module "sccs" {
  source = "github.com/cloud-native-toolkit/terraform-gitops-sccs.git?ref=v1.1.5"
  depends_on = [null_resource.setup_gitops]

  gitops_config = var.gitops_config
  git_credentials = var.git_credentials
  namespace = var.namespace
  service_account = var.name
  sccs = var.sccs
  server_name = var.server_name
}
