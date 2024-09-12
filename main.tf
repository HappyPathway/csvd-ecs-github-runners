resource "aws_ecs_cluster" "github-runner" {
  name = var.ecs_cluster_name
}


data "aws_iam_policy_document" "admin" {
  statement {
    sid = "1"

    actions = [
      "*"
    ]

    resources = [
      "*",
    ]
  }
}


resource "aws_security_group" "allow_ssh" {
  name        = "ssh-access-ecs-instances-${var.namespace}"
  description = "Security group to allow SSH from everywhere"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}


module "ecs_cluster_instances" {
  source         = "HappyPathway/instance/aws"
  instance_count = var.cluster_size
  security_group_ids = concat(
    var.security_groups,
    [
      aws_security_group.allow_ssh.id
    ]
  )
  subnet        = var.subnets[0]
  ssh_user      = "ec2-user"
  instance_type = "t2.micro"
  ami           = "ami-05c643bcdf4b2ae88"
  required_tags = {
    Name = aws_ecs_cluster.github-runner.name
  }
  root_block_device = {
    volume_size = 100
  }
  ebs_block_devices = [
    {
      device_name           = "/dev/sdb"
      volume_size           = 100
      volume_type           = "gp2"
      delete_on_termination = true
    }
  ]
  troubleshoot     = false
  project_name     = var.namespace
  windows_instance = false
  iam_policy       = data.aws_iam_policy_document.admin.json
  store_key        = true
  secret_path      = "/ssh-keys/ecs-clusters/${var.namespace}"
  config = {
    content = templatefile("${path.root}/ecs_cluster_init.sh",
      {
        cluster_name = aws_ecs_cluster.github-runner.name
    }),
    script = "/opt/config.sh"
    args   = ""
  }
  depends_on = [
    aws_ecs_cluster.github-runner
  ]
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
