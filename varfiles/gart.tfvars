# The name of the ECS cluster
image_name       = "github-runner"
image_version    = "1.23.0"

ecs_cluster_name = "ecs-ghe-runners"
vpc_id           = "vpc-00576a396ec570b94"

namespace        = "gart-ghe-runner"
repo_org         = "GART"
server_url       = "https://github.e.it.census.gov"
subnets = [
  "subnet-04b80d7ce5199f82b"
]

security_groups = [
  # "sg-0d828d223df9834a6"
  "sg-0641c697588b9aa6b"
]

github_runners = [
{
  hostname = "gart-runners"
  labels = [
    "ecs-github-runner"
  ]
  tag       = "ghe-runner"
  runner_group = {
    create = true,
    name   = "gart-production"
  }
}
]

