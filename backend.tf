terraform {
  backend "s3" {
    bucket  = "terraform-state-jenkins5533"
    key     = "ecs-deployment-jenkins/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true

    ## enable native locking
    use_lockfile = true
  }
}
