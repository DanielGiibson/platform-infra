terraform {
  required_version = ">= 1.7"
  required_providers { aws = { source = "hashicorp/aws", version = "~> 5.0" } }
  backend "s3" { bucket = "tf-state-prod"; key = "platform.tfstate"; region = "us-east-1"; encrypt = true }
}
provider "aws" {
  region = "us-east-1"
  default_tags { tags = { env = "prod", managed-by = "terraform" } }
}
module "vpc" {
  source = "./modules/vpc"
  cidr   = "10.0.0.0/16"
  azs    = ["us-east-1a", "us-east-1b", "us-east-1c"]
}
module "eks" {
  source             = "./modules/eks"
  cluster_name       = "prod-cluster"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  kubernetes_version = "1.29"
  node_instance_type = "m6i.xlarge"
  desired_capacity   = 3
}
