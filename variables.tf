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
    repo_name = optional(string, null)
    labels    = optional(list(string))
    subnets   = optional(list(string))
    tag       = optional(string)
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

  validation {
    condition     = length(var.subnets) > 0
    error_message = "The list of subnets must not be empty."
  }
}
