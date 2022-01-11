
variable "gitops_config" {
  type        = object({
    boostrap = object({
      argocd-config = object({
        project = string
        repo = string
        url = string
        path = string
      })
    })
    infrastructure = object({
      argocd-config = object({
        project = string
        repo = string
        url = string
        path = string
      })
      payload = object({
        repo = string
        url = string
        path = string
      })
    })
    services = object({
      argocd-config = object({
        project = string
        repo = string
        url = string
        path = string
      })
      payload = object({
        repo = string
        url = string
        path = string
      })
    })
    applications = object({
      argocd-config = object({
        project = string
        repo = string
        url = string
        path = string
      })
      payload = object({
        repo = string
        url = string
        path = string
      })
    })
  })
  description = "Config information regarding the gitops repo structure"
}

variable "git_credentials" {
  type = list(object({
    repo = string
    url = string
    username = string
    token = string
  }))
  description = "The credentials for the gitops repo(s)"
}

variable "namespace" {
  type        = string
  description = "The namespace where the application should be deployed"
}

variable "name" {
  type        = string
  description = "The name of the service account that should be created"
}

variable "rbac_rules" {
  type        = list(object({
    apiGroups = list(string)
    resources = list(string)
    resourceNames = optional(list(string))
    verbs     = list(string)
  }))
  description = "Rules for rbac rules"
  default     = []
}

variable "sccs" {
  type        = list(string)
  description = "The list of sccs that should be generated for the service account (valid values are anyuid and privileged)"
  default     = []
}

variable "pull_secrets" {
  type        = list(string)
  description = "The list of pull secrets that should be linked to the service account"
  default     = []
}

variable "server_name" {
  type        = string
  description = "The cluster where the application will be provisioned"
  default     = "default"
}
