resource "aws_ecs_cluster" "github-runner" {
  name = var.ecs_cluster_name
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
  runner_labels = lookup(each.value, "labels", local.labels)
  subnets       = lookup(each.value, "subnets", var.subnets)
  tag           = lookup(each.value, "tag", "github-runner")
  depends_on    = [
    aws_ecs_cluster.github-runner
  ]
}
