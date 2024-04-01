terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region  = "ap-northeast-2"
  profile = "prod-daedong2"
}

provider "aws" {
  alias   = "virginia"
  region  = "us-east-1"
}
