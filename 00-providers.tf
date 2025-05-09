provider "aws" {
  region = "us-east-1"
}
provider "tls" {

}
provider "random" {

}

provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.otel-demo.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.otel-demo.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.otel-demo.id]
      command     = "aws"
    }
  }
}

data "aws_eks_cluster_auth" "eks" {
  name = var.eks_cluster
}
provider "kubernetes" {
  host = aws_eks_cluster.otel-demo.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.otel-demo.certificate_authority[0].data)
  token = data.aws_eks_cluster_auth.eks.token
 
}

terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}
