resource "aws_ecs_cluster" "github-runner" {
  name = var.ecs_cluster_name
}

data "aws_region" "current" {}

resource "aws_vpc_endpoint" "ecr" {
  for_each = var.create_vpc_endpoint ? toset([
    "com.amazonaws.${data.aws_region.current.name}.ecr.api",
    "com.amazonaws.${data.aws_region.current.name}.ecr.dkr"
  ]) : toset([])
  vpc_id            = var.vpc_id
  service_name      = each.value
  vpc_endpoint_type = "Interface"

  security_group_ids = distinct(compact(flatten(concat(
    [
      for runner in var.github_runners : lookup(runner, "security_groups", var.security_groups)
    ],
    var.security_groups
  ))))
  private_dns_enabled = true
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

data aws_caller_identity current {}

resource "aws_cloudwatch_log_group" "function_log_group" {
  name              = "/ecs-ghe-runners/${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}"
  retention_in_days = 90
}

module "github-runner" {
  for_each      = tomap({ for runner in var.github_runners : runner.hostname => runner })
  source        = "HappyPathway/github-runner/ecs"
  ecs_cluster   = aws_ecs_cluster.github-runner.name
  hostname      = each.value.hostname
  image         = "229685449397.dkr.ecr.us-gov-west-1.amazonaws.com/docker-image-pipeline/${var.image_name}:${var.image_version}"
  repo_org      = var.repo_org
  repo_name     = each.value.repo_name
  namespace     = "${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}"
  log_group     = aws_cloudwatch_log_group.function_log_group.name
  runner_group  = each.value.runner_group
  runner_labels = [
    each.value.hostname,
    "${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}",
    data.aws_caller_identity.current.account_id,
    data.aws_region.current.name,
    "ecs-github-runner"
  ]
  certs = {
    bucket = "image-pipeline-assets"
    key    = "katello-server-ca.pem"
  }
  network_configuration = {
    subnets = coalescelist(
      lookup(each.value, "subnets", var.subnets),
      var.subnets
    )
    security_groups = coalescelist(
      lookup(each.value, "security_groups", var.security_groups),
      var.security_groups
    )
    assign_public_ip = lookup(each.value, "assign_public_ip", var.assign_public_ip)
  }
  tag = lookup(each.value, "tag", "github-runner")
  depends_on = [
    aws_ecs_cluster.github-runner
  ]
}
