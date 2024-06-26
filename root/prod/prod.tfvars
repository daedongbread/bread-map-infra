env    = "prod"
github_organization = "daedongbread"
domain = "daedongbread.com"

# vpc
availability_zones = ["ap-northeast-2a", "ap-northeast-2c"]
vpc_cidr           = "172.31.0.0/16"

# ec2
instance_type    = "t2.small"
min_size         = 1
max_size         = 1
desired_capacity = 1
key_pair_name    = "daedong"

# ecs
api_image_tag = "e575296114f85599f99d49ba819c1ad11a504fcf"

api_cpu = 512 # 0.5 vCPU
api_memory = 819 # 0.8 GB
