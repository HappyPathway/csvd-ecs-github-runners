resource "aws_ecs_cluster" "github-runner" {
  name = var.ecs_cluster_name
}


resource "aws_ecs_cluster_capacity_providers" "fargate" {
  cluster_name = aws_ecs_cluster.github-runner.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

locals {
  labels = [
    "self-hosted",
    "ecs",
    "github-runner"
  ]
}

module "github-runner" {
  for_each      = tomap({ for runner in var.github_runners : runner.hostname => runner })
  source        = "HappyPathway/github-runner/ecs"
  ecs_cluster   = aws_ecs_cluster.github-runner.name
  hostname      = each.value.hostname
  image         = "public.ecr.aws/h1g9x7n8/github-runner:1.22.20"
  repo_org      = var.repo_org
  repo_name     = each.value.repo_name
  namespace     = var.namespace
  runner_group  = each.value.runner_group
  runner_labels = lookup(each.value, "labels", local.labels)
  network_configuration = {
    subnets          = lookup(each.value, "subnets", var.subnets),
    security_groups  = lookup(each.value, "security_groups", var.security_groups)
    assign_public_ip = lookup(each.value, "assign_public_ip", var.assign_public_ip)
  }
  tag = lookup(each.value, "tag", "github-runner")
  depends_on = [
    aws_ecs_cluster.github-runner
  ]
}
