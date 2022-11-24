terraform {
  required_providers {
    # https://registry.terraform.io/providers/hashicorp/aws/latest
    aws = {
      source = "hashicorp/aws"
      # https://jubianchi.github.io/semver-check/#/~%3E%204.31/4.34
      # >= 4.31.0 <5.0.0
      version = "~> 4.31"
    }

    # https://registry.terraform.io/providers/hashicorp/local/latest
    local = {
      source = "hashicorp/local"
      # https://jubianchi.github.io/semver-check/#/~%3E%202.2/2.5
      # >= 2.2.0 <3.0.0
      version = "~> 2.2"
    }

    # https://registry.terraform.io/providers/gavinbunney/kubectl/latest
    kubectl = {
      source = "gavinbunney/kubectl"
      # >= 1.14.0 <2.0.0
      version = "~> 1.14"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
