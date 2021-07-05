locals {
  layer = "infrastructure"
  config_project = var.config_projects[local.layer]
  application_branch = "main"
  application_repo_path = "${var.application_paths[local.layer]}/namespace/${var.namespace}"
}

resource null_resource setup_application {
  provisioner "local-exec" {
    command = "${path.module}/scripts/setup-application.sh '${var.application_repo}' '${local.application_repo_path}' '${var.namespace}' '${var.name}'"

    environment = {
      TOKEN = var.application_token
    }
  }
}

resource null_resource setup_argocd {
  depends_on = [null_resource.setup_application]
  provisioner "local-exec" {
    command = "${path.module}/scripts/setup-argocd.sh '${var.config_repo}' '${var.config_paths[local.layer]}' '${local.config_project}' '${var.application_repo}' '${local.application_repo_path}' '${var.namespace}' '${local.application_branch}'"

    environment = {
      TOKEN = var.config_token
    }
  }
}
