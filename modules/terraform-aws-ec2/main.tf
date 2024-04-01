locals {
  ami = "ami-0e96230fc6327a5ec"
}

resource "aws_launch_template" "ecs_launch_template" {
  name   = "${var.env}-daedong-launch-template"
  image_id      = local.ami
  instance_type = var.instance_type
  key_name = data.aws_key_pair.daedong.key_name

  vpc_security_group_ids = [var.ecs_security_group_id]

  iam_instance_profile {
    arn = var.ecs_instance_profile_arn
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              echo ECS_CLUSTER=${var.ecs_cluster_name} >> /etc/ecs/ecs.config;
              EOF
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "daedong" {
  name                 = "${var.env}-daedong"
  launch_template {
    id      = aws_launch_template.ecs_launch_template.id
    version = "$Latest"
  }

  min_size             = var.min_size
  max_size             = var.max_size
  desired_capacity     = var.desired_capacity

  vpc_zone_identifier = var.svc_pub_subnet_ids
  
  default_cooldown          = 300
}

data "aws_key_pair" "daedong" {
  key_name           = var.key_pair_name
}
