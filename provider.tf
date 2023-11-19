terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.26.0"
    }
  }
}

provider "aws" {
  access_key = var.aws-config.access_key
  secret_key = var.aws-config.secret_key
  region  = var.aws-config.region_primary
  default_tags {
    tags = {
      environment = var.aws-config.environment
      owner       = var.aws-config.owner
    }
  }
}