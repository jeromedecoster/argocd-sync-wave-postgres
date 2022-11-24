terraform {
  required_providers {
    # https://registry.terraform.io/providers/hashicorp/aws/latest
    aws = {
      source = "hashicorp/aws"
      # https://jubianchi.github.io/semver-check/#/~%3E%204.31/4.34
      # >= 4.31.0 <5.0.0
      version = "~> 4.31"
    }

    # https://registry.terraform.io/providers/hashicorp/null/latest
    local = {
      source = "hashicorp/local"
      # >= 2.2.0 <3.0.0
      version = "~> 2.2"
    }
  }
}