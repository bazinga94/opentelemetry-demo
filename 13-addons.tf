//pod identity does not work with fargate
//Fargate doesn't support IRSA, so you can't assign IAM roles per pod/service account. Instead, all Fargate pods in a profile share a single IAM role, which limits fine-grained access control.
//fargate will assign access to aws services via the execution role
resource "aws_eks_addon" "pod_identity_agent" {
  cluster_name   = aws_eks_cluster.otel-demo.name
  addon_name     = "eks-pod-identity-agent"
}

//cloudwatch-addon
resource "aws_eks_addon" "cloudwatch" {
  depends_on = [ aws_eks_node_group.node_group, aws_eks_addon.pod_identity_agent ]
  cluster_name = aws_eks_cluster.otel-demo.name
  addon_name = "amazon-cloudwatch-observability"
  resolve_conflicts_on_update = "OVERWRITE"
  resolve_conflicts_on_create = "NONE"
  pod_identity_association {
      service_account = "cloudwatch-agent"
      role_arn        = aws_iam_role.cw.arn
  }
}

//ebs-csi addon:
resource "aws_eks_addon" "ebs-csi" {
  depends_on = [ aws_eks_addon.pod_identity_agent ]
  cluster_name = aws_eks_cluster.otel-demo.name
  addon_name = "aws-ebs-csi-driver"
  pod_identity_association {
    service_account = "ebs-csi-controller-sa"
    role_arn = aws_iam_role.ebs-csi.arn
  }
  resolve_conflicts_on_update = "OVERWRITE"
}

//vpc-cni addon:
resource "aws_eks_addon" "vpc-cni" {
  depends_on = [ aws_eks_addon.pod_identity_agent ]
  cluster_name = aws_eks_cluster.otel-demo.name
  addon_name = "vpc-cni"
  pod_identity_association {
      service_account = "aws-node"
      role_arn        = aws_iam_role.vpc-cni.arn
  }
  resolve_conflicts_on_update = "OVERWRITE"
}




//https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/install-CloudWatch-Observability-EKS-addon.html?icmpid=docs_eks_help_panel_hp_add_ons_cloudwatch
//https://docs.aws.amazon.com/eks/latest/userguide/pod-id-agent-setup.html