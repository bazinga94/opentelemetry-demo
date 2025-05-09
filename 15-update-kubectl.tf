
resource "null_resource" "update_kubeconfig" {
  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name ${aws_eks_cluster.otel-demo.name} --region us-east-1"
  }

  depends_on = [aws_eks_cluster.otel-demo]
}

resource "null_resource" "create_namespace" {
  provisioner "local-exec" {
    command = "kubectl create namespace otel-demo"
  }

  depends_on = [null_resource.update_kubeconfig]
}