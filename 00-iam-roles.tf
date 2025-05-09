#ControlTower IAM Role and Policy Attachment
resource "aws_iam_role" "ec2_role" {
  name = "ControlTowerRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "ec2_policy" {
  name        = "EC2Policy"  
  description = "Policy to allow EC2 instances to use necessary services"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      #put logs
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup", 
          "logs:CreateLogStream", 
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
      # eks access
      {
        Effect = "Allow"
        Action = [
          "eks:*",
        ]
        Resource = "*"
      },
      #access to specific keys for extraction
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = "*"
      },
      #access to ebs keys for encryption
      {
        Effect = "Allow"
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = aws_kms_key.kms_ebs.arn
      },
      {
        Effect = "Allow"
        Action = [
          "autoscaling:*"
        ]
        Resource = "*"
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "ec2_iam_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_policy.arn
}
resource "aws_iam_instance_profile" "ec2" {
  name = "EKS_EC2_ControlTower"
  role = aws_iam_role.ec2_role.name
}

//node role

resource "aws_iam_role" "node" {
  name = "eks-node-group-role-policy"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["sts:AssumeRole"]
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "otel-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "otel-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "otel-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node.name
}

//cluster role

resource "aws_iam_role" "cluster" {
  name = "eks-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}
resource "aws_iam_policy" "kms_eks_access" {
  name = "eks-cluster-role-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      #put logs
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup", 
          "logs:CreateLogStream", 
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
      #access to specific keys for extraction
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = "*"
      },
      #access to ebs keys for encryption
      {
        Effect = "Allow"
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = aws_kms_key.kms_eks.arn
      },
      {
        Effect = "Allow"
        Action = [
          "autoscaling:*"
        ]
        Resource = "*"
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster_kmsaccess" {
  policy_arn = aws_iam_policy.kms_eks_access.arn
  role = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSComputePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSComputePolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSBlockStoragePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSBlockStoragePolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSLoadBalancingPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSLoadBalancingPolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSNetworkingPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSNetworkingPolicy"
  role       = aws_iam_role.cluster.name
}

//fargate role:
//attach policies of the services you want your pods to have access to
//not a good option for least privilege principal
# resource "aws_iam_role" "fargate" {
#   name = "eks-fargate-profile-otel"

#   assume_role_policy = jsonencode({
#     Statement = [{
#       Action = "sts:AssumeRole"
#       Effect = "Allow"
#       Principal = {
#         Service = "eks-fargate-pods.amazonaws.com"
#       }
#     }]
#     Version = "2012-10-17"
#   })
# }

# resource "aws_iam_role_policy_attachment" "otel-AmazonEKSFargatePodExecutionRolePolicy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
#   role       = aws_iam_role.fargate.name
# }