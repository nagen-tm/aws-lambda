terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.8"
    }
    archive = {
      source = "hashicorp/aws"
      version = "~> 2.2"
    }
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      "cloud-vendor" = "aws"
      "github-repo" = "nagengtm/aws-lambda"
    }
  }
}