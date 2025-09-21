module "vpc" {
source = "terraform-aws-modules/vpc/aws"
version = "~> 4.0"


name = "flask-eks-vpc"
cidr = var.vpc_cidr


azs = slice(data.aws_availability_zones.available.names, 0, 3)
public_subnets = var.public_subnets
private_subnets = var.private_subnets


enable_nat_gateway = true
}


module "eks" {
source = "terraform-aws-modules/eks/aws"
version = "~> 19.0"


cluster_name = var.cluster_name
cluster_version = "1.26"


subnets = module.vpc.private_subnets


node_groups = {
default = {
desired_capacity = var.node_group_desired_capacity
min_capacity = var.node_group_min_size
max_capacity = var.node_group_max_size


instance_type = "t3.medium"
key_name = null
}
}


manage_aws_auth = true
}


resource "aws_ecr_repository" "app_repo" {
name = "${var.cluster_name}-flask-app"
image_tag_mutability = "MUTABLE"
encryption_configuration {
encryption_type = "AES256"
}
}