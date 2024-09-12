terraform {
  backend "s3" {
    bucket         = "inf-tfstate-229685449397"
    key            = "csvd-dev-gov/common/apps/ecs-github-runners"
    region         = "us-gov-east-1"
    dynamodb_table = "tf_remote_state"
  }
}
