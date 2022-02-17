terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=3.12.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.3"
    }
  }
  required_version = ">= 0.13"
}
