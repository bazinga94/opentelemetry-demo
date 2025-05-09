data "aws_ssm_parameter" "eks_ami_release_version" {
  name = "/aws/service/eks/optimized-ami/${aws_eks_cluster.otel-demo.version}/amazon-linux-2023/x86_64/standard/recommended/release_version"
}
resource "aws_eks_node_group" "node_group" {
  cluster_name    = aws_eks_cluster.otel-demo.name
  version = aws_eks_cluster.otel-demo.version
  instance_types = [ var.instance_type_value ]
  release_version = nonsensitive(data.aws_ssm_parameter.eks_ami_release_version.value)
  node_group_name = "worker-nodes"
  capacity_type = "SPOT"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = [for subnet in aws_subnet.private-subnet : subnet.id]
  
  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role.node
  ]
}