module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.cluster_name}-vpc"
  cidr = var.vpc_cidr

  azs             = ["ap-south-1a", "ap-south-1b"]
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Project     = var.cluster_name
    Environment = "production"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.29"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  enable_cluster_creator_admin_permissions = true


  enable_irsa = true

  eks_managed_node_groups = {
    default = {
      name           = "game-2048-ng"
      instance_types = [var.node_instance_type]

      desired_size = var.desired_nodes
      min_size     = var.min_nodes
      max_size     = var.max_nodes
    }
  }

  tags = {
    Project     = var.cluster_name
    Environment = "production"
  }
}

