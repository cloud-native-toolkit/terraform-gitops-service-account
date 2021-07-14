locals {
  layer = "infrastructure"
  layer_config = var.gitops_config[local.layer]
  application_branch = "main"
  config_namespace = "default"
  yaml_dir = "${path.cwd}/.tmp/sa-${var.name}"
}

resource null_resource create_yaml {
  provisioner "local-exec" {
    command = "${path.module}/scripts/create-yaml.sh '${local.yaml_dir}/namespace/${var.namespace}' '${var.name}'"
  }
}

resource null_resource setup_gitops {
  depends_on = [null_resource.create_yaml]

  provisioner "local-exec" {
    command = "${path.module}/scripts/setup-gitops.sh '${var.name}' '${local.yaml_dir}' 'namespace/${var.namespace}' '${local.application_branch}' '${var.namespace}'"

    environment = {
      GIT_CREDENTIALS = jsonencode(var.git_credentials)
      GITOPS_CONFIG = jsonencode(local.layer_config)
    }
  }
}

module "rbac" {
  source = "github.com/cloud-native-toolkit/terraform-gitops-rbac.git"
  depends_on = [null_resource.setup_gitops]

  gitops_config             = var.gitops_config
  git_credentials           = var.git_credentials
  service_account_namespace = var.namespace
  service_account_name      = var.name
  namespace                 = var.namespace
  rules                     = var.rbac_rules
}
