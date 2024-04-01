locals {
    az_num = length(var.availability_zones)
    az_name = local.az_num == 2 ? ["a", "c"] : local.az_num == 3 ? ["a", "b", "c"] : local.az_num == 4 ? ["a", "b", "c", "d"] : []
    default_cidr = "0.0.0.0/0"
    endpoint_type = {
        gateway = "Gateway"
    }
}

# vpc
resource "aws_vpc" "vpc" {
    cidr_block           = var.vpc_cidr # 172.31.0.0/16
    enable_dns_hostnames = true
    enable_dns_support   = true

    tags = {
        Name = "${var.env}-daedong-vpc"
    }
}

# subnet
## public subnet
resource "aws_subnet" "lb_pub" {
    count                   = local.az_num
    vpc_id                  = aws_vpc.vpc.id
    cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index) # 172.31.0.0/24
    availability_zone       = element(var.availability_zones, count.index)
    map_public_ip_on_launch = true
    
    tags = {
        Name = "${var.env}-daedong-lb-pub-${local.az_name[count.index]}"
        Description = "public subnet for lb"
    }
}

resource "aws_subnet" "svc_pub" {
    count                   = local.az_num
    vpc_id                  = aws_vpc.vpc.id
    cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index + 4) # 172.31.4.0/24
    availability_zone       = element(var.availability_zones, count.index)
    map_public_ip_on_launch = true
    
    tags = {
        Name = "${var.env}-daedong-svc-pub-${local.az_name[count.index]}"
        Description = "public subnet for service"
    }
}

resource "aws_subnet" "infra_pub" {
    count                   = local.az_num
    vpc_id                  = aws_vpc.vpc.id
    cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index + 16) # 172.31.16.0/24
    availability_zone       = element(var.availability_zones, count.index)
    map_public_ip_on_launch = true
    
    tags = {
        Name = "${var.env}-daedong-infra-pub-${local.az_name[count.index]}"
        Description = "public subnet for infra"
    }
}

# private subnet
resource "aws_subnet" "lb_prv" {
    count                   = local.az_num
    vpc_id                  = aws_vpc.vpc.id
    cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index + 128) # 172.31.128.0/24
    availability_zone       = element(var.availability_zones, count.index)
    map_public_ip_on_launch = true
    
    tags = {
        Name = "${var.env}-daedong-lb-prv-${local.az_name[count.index]}"
        Description = "private subnet for lb"
    }
}

resource "aws_subnet" "svc_prv" {
    count                   = local.az_num
    vpc_id                  = aws_vpc.vpc.id
    cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index + 132) # 172.31.132.0/24
    availability_zone       = element(var.availability_zones, count.index)

    tags = {
        Name = "${var.env}-daedong-svc-prv-${local.az_name[count.index]}"
        Description = "private subnet for service"
    }
}

resource "aws_subnet" "infra_prv" {
    count                   = local.az_num
    vpc_id                  = aws_vpc.vpc.id
    cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index + 144) # 172.31.144.0/24
    availability_zone       = element(var.availability_zones, count.index)

    tags = {
        Name = "${var.env}-daedong-infra-prv-${local.az_name[count.index]}"
        Description = "private subnet for infra"
    }
}

resource "aws_subnet" "db_prv" {
    count                   = local.az_num
    vpc_id                  = aws_vpc.vpc.id
    cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index + 156) # 172.31.156.0/24
    availability_zone       = element(var.availability_zones, count.index)

    tags = {
        Name = "${var.env}-daedong-db-prv-${local.az_name[count.index]}"
        Description = "private subnet for database"
    }
}

# internet gateway
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vpc.id

    tags = {
        Name = "${var.env}-daedong-igw"
    }
}

# route table
resource "aws_route_table" "lb_pub" {
    vpc_id = aws_vpc.vpc.id
    route {
        cidr_block = local.default_cidr
        gateway_id = aws_internet_gateway.igw.id
    }

    tags = {
        Name = "lb public route table"
    }
}

resource "aws_route_table" "svc_pub" {
    vpc_id = aws_vpc.vpc.id
    route {
        cidr_block = local.default_cidr
        gateway_id = aws_internet_gateway.igw.id
    }

    tags = {
        Name = "service public route table"
    }
}

resource "aws_route_table" "infra_pub" {
    vpc_id = aws_vpc.vpc.id
    route {
        cidr_block = local.default_cidr
        gateway_id = aws_internet_gateway.igw.id
    }

    tags = {
        Name = "infra public route table"
    }
}

resource "aws_route_table" "svc_prv" {
    vpc_id = aws_vpc.vpc.id
    # route {
    #     cidr_block = local.default_cidr
    #     nat_gateway_id = var.nat_gw_id
    # }

    tags = {
        Name = "service private route table"
    }
}

resource "aws_route_table" "infra_prv" {
    vpc_id = aws_vpc.vpc.id

    tags = {
        Name = "service private route table"
    }
}

resource "aws_route_table" "db_prv" {
    vpc_id = aws_vpc.vpc.id

    tags = {
        Name = "db private route table"
    }
}

resource "aws_route_table_association" "lb_pub" {
    count          = local.az_num
    subnet_id      = element(aws_subnet.lb_pub[*].id, count.index)
    route_table_id = aws_route_table.lb_pub.id
}

resource "aws_route_table_association" "svc_pub" {
    count          = local.az_num
    subnet_id      = element(aws_subnet.svc_pub[*].id, count.index)
    route_table_id = aws_route_table.svc_pub.id
}

resource "aws_route_table_association" "infra_pub" {
    count          = local.az_num
    subnet_id      = element(aws_subnet.infra_pub[*].id, count.index)
    route_table_id = aws_route_table.infra_pub.id
}

resource "aws_route_table_association" "svc_prv" {
    count          = local.az_num
    subnet_id      = element(aws_subnet.svc_prv[*].id, count.index)
    route_table_id = aws_route_table.svc_prv.id
}

resource "aws_route_table_association" "infra_prv" {
    count          = local.az_num
    subnet_id      = element(aws_subnet.infra_prv[*].id, count.index)
    route_table_id = aws_route_table.infra_prv.id
}

resource "aws_route_table_association" "db_prv" {
    count          = local.az_num
    subnet_id      = element(aws_subnet.db_prv[*].id, count.index)
    route_table_id = aws_route_table.db_prv.id
}

# endpoint
resource "aws_vpc_endpoint" "s3_endpoint" {
    service_name      = "com.amazonaws.ap-northeast-2.s3"
    vpc_endpoint_type = local.endpoint_type.gateway

    vpc_id            = aws_vpc.vpc.id
	route_table_ids   = [aws_route_table.svc_pub.id]
}

resource "aws_vpc_endpoint_policy" "s3_endpoint_policy" {
    vpc_endpoint_id = aws_vpc_endpoint.s3_endpoint.id
    policy = data.aws_iam_policy_document.s3_endpoint_policy.json
    # policy = jsonencode({
    #     Version : "2012-10-17",
    #     Statement: [
    #         {
    #             Sid: "Access to S3 Bucket",
    #             Effect: "Allow",
    #             Principal: "*",
    #             Action: [
    #                 "s3:ListBucket",
    #                 "s3:PutObject"
    #             ],
    #             Resource: [
    #                 "${var.image_bucket_arn}",
    #                 "${var.image_bucket_arn}/*",
    #             ],
    #             Condition: {
    #                 ArnEquals: {
    #                     "aws:PrincipalArn": var.ecs_task_role_arn
    #                 }
    #             }
    #         },
    #         {
    #             Sid: "Access-to-ECR-buckets",
    #             Effect: "Allow",
    #             Principal: "*",
    #             Action: [
    #                 "s3:GetObject"
    #             ],
    #             Resource: [
    #                 "arn:aws:s3:::prod-ap-northeast-2-starport-layer-bucket/*"
    #             ]
    #         }
    #     ]
    # })
}

resource "aws_vpc_endpoint_route_table_association" "svc_pub_s3_endpoint" {
    count           = local.az_num
    route_table_id = aws_route_table.svc_pub.id
    vpc_endpoint_id = aws_vpc_endpoint.s3_endpoint.id
}
