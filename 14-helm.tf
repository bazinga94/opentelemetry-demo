resource "null_resource" "update_helm" {
  provisioner "local-exec" {
    command = "helm repo update"
  }

  depends_on = [aws_eks_cluster.otel-demo]
}
resource "helm_release" "alb" {
  name = "aws-load-balancer-controller"

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.8.1"

  set {
    name  = "clusterName"
    value = aws_eks_cluster.otel-demo.id
  }

  set {
    name  = "serviceAccount.name"
    value = "alb-ingress-controller"
  }

  set {
    name  = "vpcId"
    value = aws_vpc.main.id
  }

  depends_on = [
    aws_eks_node_group.node_group,
    aws_iam_role_policy_attachment.alb
  ]
}