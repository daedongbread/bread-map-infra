env    = "stage"
github_organization = "daedongbread"
domain = "stage.daedongbread.com"

# vpc
availability_zones = ["ap-northeast-2a", "ap-northeast-2c"]
vpc_cidr           = "172.31.0.0/16"

# ec2
instance_type    = "t2.micro"
min_size         = 1
max_size         = 1
desired_capacity = 1
key_pair_name    = "daedong"

# ecs
api_image_tag = "76c1ca444645ab3dd9509b0f62249fbdc93d1099"

api_cpu = 256 # 0.25 vCPU
api_memory = 410 # 0.4 GB
