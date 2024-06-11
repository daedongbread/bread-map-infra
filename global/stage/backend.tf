terraform {
    backend "s3" {
        bucket         = "stage-daedong-terraform-remote-state-637423658689" // TODO
        key            = "global/stage/terraform.tfstate"        // TODO
        region         = "ap-northeast-2"
        dynamodb_table = "stage-daedong-terraform-state-lock-637423658689" // TODO
        encrypt        = true
    }
}
