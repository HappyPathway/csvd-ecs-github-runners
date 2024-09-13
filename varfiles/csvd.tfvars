# The name of the ECS cluster
ecs_cluster_name = "ecs-ghe-runners"
vpc_id =  "vpc-00576a396ec570b94"
namespace = "csvd-ghe-runner"
repo_org = "CSVD"
subnets = [
  "subnet-04b80d7ce5199f82b"
]
security_groups = [
  # "sg-0d828d223df9834a6"
  "sg-0641c697588b9aa6b"
]
github_runners = [{
  hostname = "csvd-gh-runner"
  labels = [
    "automation-repos",
    "ecs-github-runner"
  ]
  repo_name = "automation-repos"
  tag = "ghe-runner"
  runner_group  = {
    create = false
  }
}]

