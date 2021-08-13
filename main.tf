locals {
  bin_dir = "${path.cwd}/bin"
  layer = "infrastructure"
  yaml_dir = "${path.cwd}/.tmp/sa-${var.name}/namespace/${var.namespace}"
  name = "${var.name}-sa"
}

resource null_resource setup_binaries {
  provisioner "local-exec" {
    command = "${path.module}/scripts/setup-binaries.sh"

    environment = {
      BIN_DIR = local.bin_dir
    }
  }
}

resource null_resource create_yaml {
  provisioner "local-exec" {
    command = "${path.module}/scripts/create-yaml.sh '${local.yaml_dir}' '${var.name}'"
  }
}

resource null_resource setup_gitops {
  depends_on = [null_resource.create_yaml]

  provisioner "local-exec" {
    command = "$(command -v igc || command -v ${local.bin_dir}/igc) gitops-module '${local.name}' -n '${var.namespace}' --contentDir '${local.yaml_dir}' --serverName '${var.server_name}' -l '${local.layer}'"

    environment = {
      GIT_CREDENTIALS = yamlencode(var.git_credentials)
      GITOPS_CONFIG   = yamlencode(var.gitops_config)
    }
  }
}

module "rbac" {
  source = "github.com/cloud-native-toolkit/terraform-gitops-rbac.git?ref=v1.5.1"
  depends_on = [null_resource.setup_gitops]

  gitops_config             = var.gitops_config
  git_credentials           = var.git_credentials
  service_account_namespace = var.namespace
  service_account_name      = var.name
  namespace                 = var.namespace
  rules                     = var.rbac_rules
  serverName = var.server_name
}

module "sccs" {
  source = "github.com/cloud-native-toolkit/terraform-gitops-sccs.git?ref=v1.1.0"
  depends_on = [null_resource.setup_gitops]

  gitops_config = var.gitops_config
  git_credentials = var.git_credentials
  namespace = var.namespace
  service_account = var.name
  sccs = var.sccs
  serverName = var.server_name
}
