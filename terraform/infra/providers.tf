terraform {
  required_providers {
    # https://registry.terraform.io/providers/hashicorp/aws/latest
    aws = {
      source = "hashicorp/aws"
      # https://jubianchi.github.io/semver-check/#/~%3E%204.31/4.34
      # >= 4.31.0 <5.0.0
      version = "~> 4.31"
    }

    # https://registry.terraform.io/providers/integrations/github/latest
    github = {
      source = "integrations/github"
      # https://jubianchi.github.io/semver-check/#/~%3E%205.2/5.5
      # >= 5.2.0 <6.0.0
      version = "~> 5.2"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# https://registry.terraform.io/providers/integrations/github/latest/docs
provider "github" {
  owner = var.github_owner
  token = var.github_token
}
