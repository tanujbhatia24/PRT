variable "aws_region" { type = string }
variable "cluster_name" { type = string }
variable "vpc_cidr" { type = string }
variable "public_subnets" { type = list(string) }
variable "private_subnets" { type = list(string) }
variable "node_group_desired_capacity" { type = number }
variable "node_group_min_size" { type = number }
variable "node_group_max_size" { type = number }