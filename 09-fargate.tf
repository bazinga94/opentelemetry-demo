#create fargate profiles with fargate execution policy and IAM policy that will allow your pod to use aws services merged together:
    # fargate executin policy (required) - only autoscales the pods will not give access to any services except aws fargate service
    # any service policy (optional) - attach for fine grained service access
#use the selector (namespace is required) (labels optionals/ However, it is better to allow a certain pod with their labels attached and configured so that fargate will attach to the pod and give it access to the services attached via the IAM policy)
# resource "aws_eks_fargate_profile" "otel-fargate" {
#   cluster_name           = aws_eks_cluster.otel-demo.name
#   fargate_profile_name   = "otel-fargate"
#   pod_execution_role_arn = aws_iam_role.fargate.arn
#   //These subnets must have the following resource tag: kubernetes.io/cluster/CLUSTER_NAME = owned (where CLUSTER_NAME is replaced with the name of the EKS Cluster)
#   subnet_ids             = [ for subnet in aws_subnet.private-subnet : subnet.id   ]

#   selector {
#     namespace = "otel-demo"
#   }
#   selector {
#     namespace = "default"
#   }
#   selector {
#     namespace = "kube-system"
#   }
# }