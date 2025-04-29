# Pod Identity:
1. Pod Identity has been created using terraform and assigned to a service account (alb-ingress-controller) in "default" namespace
2. This SA is used by alb controller to deploy ALB/ELB as required, it will automatically detect the vpc and subnets as they have been tagged
3. Two approaches:
    1. Deploy ALB controller manualy using kubectl (may need manual configuration)
        i. You will need to manually configure alb-deployment.yaml
        ii. You will need to assign the vpcID that's it
    2. Deploy using helm use the following command (easy):
        i. Your kubectl should be connected to your cluster
        ```bash
            helm repo add eks https://aws.github.io/eks-charts

            helm repo update

            helm install aws-load-balancer-controller eks/aws-load-balancer-controller --namespace default --set clusterName=otel-demo-1 --set serviceAccount.create=false --set serviceAccount.name=alb-ingress-controller

        ```
        ii. You need not do this as the terraform helm file defined, has already created a service account in default namespace

//https://medium.com/@KimiHuang/monitor-your-eks-cluster-by-amazon-managed-service-for-prometheus-amp-f009ba149cab - installing AMP on your cluster