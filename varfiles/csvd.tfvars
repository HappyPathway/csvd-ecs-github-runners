vpc_id = "vpc-00576a396ec570b94"
# The name of the ECS cluster
ecs_cluster_name = "ecs-ghe-runners"

# A list of GitHub runners with their configurations
github_runners = [{
  # The hostname for the GitHub runner
  hostname = "csvd-gh-runners"

  # Labels to assign to the GitHub runner
  labels = [
    "automation-repos"
  ]
  
  subnets = [
    "subnet-04b80d7ce5199f82b"
  ]
  # The repository name for the GitHub runner
  repo_name = "automation-repos"

  # Tag to assign to the GitHub runner
  tag = "ghe-runner"
  runner_group  = {
    create = false
  }
}]

# The namespace for the resources
namespace = "ghe-runner"

# The GitHub organization
repo_org = "CSVD"

# Subnets where the GitHub runner will be deployed
# if specified, the GitHub runner will be deployed in the specified subnets and will override the global subnets
subnets = [
  "subnet-04b80d7ce5199f82b"
]
