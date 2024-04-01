data "aws_ecr_repository" "api" {
    name = "${var.env}-daedong-api"
}
