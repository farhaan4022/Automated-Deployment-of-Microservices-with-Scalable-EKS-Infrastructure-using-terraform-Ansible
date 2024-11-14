# EKS Cluster Module
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.29.0"

  cluster_name                    = "myapp-eks-cluster"
  cluster_version                 = "1.31"
  cluster_endpoint_public_access  = true

  subnet_ids = module.myapp-vpc.private_subnets
  vpc_id     = module.myapp-vpc.vpc_id
  

  tags = {
    environment = "development"
    application = "myapp"
  }

  # Managed Node Group
  eks_managed_node_groups = {
    dev = {
      min_size     = 2
      max_size     = 10
      desired_size = 2
      instance_types = ["t2.small"]
    }
  }
}

# IAM Role for Fargate Pod Execution
resource "aws_iam_role" "fargate_pod_execution" {
  name = "eks-fargate-pod-execution-role"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "eks-fargate-pods.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "eks-fargate-pod-execution-role"
  }
}

# Attach required Fargate execution policy
resource "aws_iam_role_policy_attachment" "fargate_policy" {
  role       = aws_iam_role.fargate_pod_execution.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
}

# Fargate Profile for "microservices" Namespace
resource "aws_eks_fargate_profile" "microservices" {
  cluster_name           = module.eks.cluster_name
  fargate_profile_name   = "microservices-fargate-profile"
  pod_execution_role_arn = aws_iam_role.fargate_pod_execution.arn

  subnet_ids = module.myapp-vpc.private_subnets

  selector {
    namespace = "microservices"
  }

  tags = {
    Name        = "myapp-microservices-fargate"
    environment = "development"
  }
}
