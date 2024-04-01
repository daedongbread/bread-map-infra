terraform {
  backend "s3" {
    bucket         = "prod-daedong-terraform-remote-state-590183743745" // TODO
    key            = "root/prod/terraform.tfstate"        // TODO
    region         = "ap-northeast-2"
    dynamodb_table = "prod-daedong-terraform-state-lock-590183743745" // TODO
    encrypt        = true
  }
}
