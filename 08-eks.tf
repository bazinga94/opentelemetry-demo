resource "aws_eks_cluster" "otel-demo" {
  name = var.eks_cluster
  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }
  bootstrap_self_managed_addons = true
  role_arn = aws_iam_role.cluster.arn
  version  = var.eks_version
  vpc_config {
      subnet_ids = concat(
    [for subnet in aws_subnet.private-subnet : subnet.id],
    [for a in aws_subnet.public-subnet : a.id]
    )
  }
  upgrade_policy {
    support_type = "STANDARD"
  }
  encryption_config {
    provider {
      key_arn = aws_kms_key.kms_eks.arn
    }
    resources = [ "secrets" ]
  }
  //to enable auto eks un comment the following
  # compute_config {
  #   enabled = true
  #   node_pools = [ "general-purpose" ]
  #   node_role_arn = aws_iam_role.node.arn
  # }
  # kubernetes_network_config {
  #   elastic_load_balancing {
  #     enabled = true
  #   }
  #   service_ipv4_cidr = "172.20.0.0/16"
  # }
  # storage_config {
  #   block_storage {
  #     enabled = true
  #   }
  # }
  # Ensure that IAM Role permissions are created before and deleted
  # after EKS Cluster handling. Otherwise, EKS will not be able to
  # properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role.cluster,
  ]
}