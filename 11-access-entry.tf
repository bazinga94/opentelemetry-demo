resource "aws_eks_access_entry" "access_ec2" {
  cluster_name      = aws_eks_cluster.otel-demo.name
  principal_arn     = aws_iam_role.ec2_role.arn
  type              = "STANDARD"
}

//command to list out eks access policies available:
// aws eks list-access-policies --output table
//https://docs.aws.amazon.com/eks/latest/userguide/access-policy-permissions.html list of policies available to attach to access entries

resource "aws_eks_access_policy_association" "access_ec2" {
  cluster_name  = aws_eks_cluster.otel-demo.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
  principal_arn = aws_iam_role.ec2_role.arn

  access_scope {
    type       = "cluster"
  }
}


//github user access to eks
 resource "aws_eks_access_entry" "github" {
   cluster_name      = aws_eks_cluster.otel-demo.name
   principal_arn     = "arn:aws:iam::588738579349:user/Github-ci-cd"
   type              = "STANDARD"
 }

# //command to list out eks access policies available:
# // aws eks list-access-policies --output table

resource "aws_eks_access_policy_association" "github" {
  cluster_name  = aws_eks_cluster.otel-demo.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = "arn:aws:iam::588738579349:user/Github-ci-cd"

  access_scope {
    type       = "cluster"
  }
}

//console access
#  resource "aws_eks_access_entry" "console" {
#    cluster_name      = aws_eks_cluster.otel-demo.name
#    principal_arn     = "arn:aws:iam::588738579349:user/EKS_finals"
#    type              = "STANDARD"
#  }

# # //command to list out eks access policies available:
# # // aws eks list-access-policies --output table

# resource "aws_eks_access_policy_association" "console" {
#   cluster_name  = aws_eks_cluster.otel-demo.name
#   policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
#   principal_arn = "arn:aws:iam::588738579349:user/EKS_finals"

#   access_scope {
#     type       = "cluster"
#   }
# }

//console access
# resource "aws_eks_access_entry" "console" {
#   cluster_name      = aws_eks_cluster.otel-demo.name
#   principal_arn     = "arn:aws:iam::588738579349:user/EKS_finals"
#   type              = "STANDARD"
# }

# //command to list out eks access policies available:
# // aws eks list-access-policies --output table

# resource "aws_eks_access_policy_association" "console" {
#   cluster_name  = aws_eks_cluster.otel-demo.name
#   policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
#   principal_arn = aws_iam_role.console.arn

#   access_scope {
#     type       = "cluster"
#   }
# }