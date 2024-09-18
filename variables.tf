variable "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  type        = string

  validation {
    condition     = length(var.ecs_cluster_name) > 0
    error_message = "The ECS cluster name must not be empty."
  }
}

variable "github_runners" {
  description = "A list of GitHub runners"
  type = list(object({
    hostname  = string
    namespace = optional(string, null)
    repo_name = optional(string, null)
    labels    = optional(list(string))
    subnets   = optional(list(string))
    tag       = optional(string)

    network_configuration = optional(object({
      subnets          = optional(list(string), []),
      security_groups  = optional(list(string), []),
      assign_public_ip = optional(bool, false)
      }), {}
    )

    runner_group = optional(object({
      name                       = optional(string)
      visibility                 = optional(string, "selected")
      selected_workflows         = optional(list(string), [])
      selected_repository_ids    = optional(list(string), [])
      allows_public_repositories = optional(bool, false)
      create                     = optional(bool, false)
    }), { create = false })
    # end of variable definition
  }))

  validation {
    condition     = length(var.github_runners) > 0
    error_message = "The list of GitHub runners must not be empty."
  }
}

variable "repo_org" {
  description = "The GitHub organization"
  type        = string

  validation {
    condition     = length(var.repo_org) > 0
    error_message = "The GitHub organization must not be empty."
  }
}

variable "namespace" {
  description = "The namespace for the resources"
  type        = string

  validation {
    condition     = length(var.namespace) > 0
    error_message = "The namespace must not be empty."
  }
}

variable "subnets" {
  description = "A list of subnets"
  type        = list(string)
  default     = []
  validation {
    condition     = length(var.subnets) >= 0
    error_message = "The list of subnets must not be empty."
  }
}

variable "security_groups" {
  description = "A list of security groups"
  type        = list(string)
  default     = []
  validation {
    condition     = length(var.security_groups) >= 0
    error_message = "The list of security groups must not be empty."
  }
}

variable "assign_public_ip" {
  default = false
  type    = bool
}

variable "cluster_size" {
  default = 3
}

variable "vpc_id" {}

variable "create_vpc_endpoint" {
  type    = bool
  default = false
}

variable "image_name" {}
variable "image_version" {}

variable server_url {
  default = ""
}
