variable "project_name" {
  default = ""
}

variable "app_name" {
  default = ""
}

variable "aws_region" {
  default = ""
}

variable "github_owner" {
  default = ""
}

variable "github_token" {
  default   = ""
  sensitive = true
}