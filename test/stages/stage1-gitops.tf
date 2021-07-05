module "gitops" {
  source = "github.com/cloud-native-toolkit/terraform-tools-gitops"

  host = var.git_host
  type = var.git_type
  org  = var.git_org
  repo = var.git_repo
  username = var.git_username
  token = var.git_token
  gitops_namespace = var.gitops_namespace
}

resource null_resource gitops_output {
  provisioner "local-exec" {
    command = "echo -n '${module.gitops.config_repo}' > git_repo"
  }

  provisioner "local-exec" {
    command = "echo -n '${module.gitops.config_token}' > git_token"
  }
}
