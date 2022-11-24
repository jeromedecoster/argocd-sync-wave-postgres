terraform {
  required_providers {
    # https://registry.terraform.io/providers/hashicorp/aws/latest
    aws = {
      source = "hashicorp/aws"
      # https://jubianchi.github.io/semver-check/#/~%3E%204.31/4.34
      # >= 4.31.0 <5.0.0
      version = "~> 4.31"

      # Make it faster by skipping something
      # https://registry.terraform.io/providers/hashicorp/aws/latest/docs#skip_get_ec2_platforms
      # skip_get_ec2_platforms      = true
      # https://registry.terraform.io/providers/hashicorp/aws/latest/docs#skip_metadata_api_check
      # skip_metadata_api_check     = true
      # https://registry.terraform.io/providers/hashicorp/aws/latest/docs#skip_region_validation
      # skip_region_validation      = true
      # https://registry.terraform.io/providers/hashicorp/aws/latest/docs#skip_credentials_validation
      # skip_credentials_validation = true
      # https://registry.terraform.io/providers/hashicorp/aws/latest/docs#skip_requesting_account_id
      # skip_requesting_account_id  = true
    }

    # https://registry.terraform.io/providers/paultyng/git/latest/docs
    git = {
      source  = "paultyng/git"
      version = "0.1.0"
    }

    # https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.22"
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs
provider "aws" {
  region = var.aws_region
}

# https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs
provider "docker" {
  registry_auth {
    # address = "xxx.dkr.ecr.xxx.amazonaws.com"
    address = local.repository_address
    # username = data.aws_ecr_authorization_token.token.user_name
    username = "AWS"
    password = data.aws_ecr_authorization_token.token.password
  }
}
