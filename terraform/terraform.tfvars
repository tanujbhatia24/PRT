aws_region                  = "ap-south-1"
cluster_name                = "flask-eks-cluster"
vpc_cidr                    = "10.0.0.0/16"

public_subnets              = [
  "10.0.0.0/24",
  "10.0.1.0/24",
  "10.0.2.0/24"
]

private_subnets             = [
  "10.0.10.0/24",
  "10.0.11.0/24",
  "10.0.12.0/24"
]

node_group_desired_capacity = 2
node_group_min_size         = 1
node_group_max_size         = 3
