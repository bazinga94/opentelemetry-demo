# Architecture Diagram Overview:
<image src="/images/microservice-architecture.png">

# loosely-coupled microservices:
## These images are obtained via jaeger:
<image src="/images/jaegar-1.png">
<image src="/images/jaegar-2.png">
<image src="/images/jaeger-3.png">
<image src="/images/jaeger-4.png">
<image src="/images/jaeger5.png">
<image src="/images/jaeger6.png">
# How to use Terraform:
```bash
    terraform fmt #formats the code (optional)

    terraform validate # optional

    terraform plan # check if any errors are occuring during the staging phase

    terraform apply 

```

# Pre-requisites:

1. Install terraform and add it to your path

2. Create a IAM user Admin with AdminAccess Policy

3. Create access credentials that can be used in aws cli

4. Configure your aws cli using the token

5. Hosted Zones (either via Route53 DNS or Import from other domain)

6. SSL/TLS certificate for the loadblancers issued via ACM

7. Install kubectl on your instance/local machine

8. Install helm on your instance/local machine

9. Use the following command to add the required helm repo:
    ```bash
    helm add repo eks https://aws.github.io/eks-charts
    helm repo update
    ```


# Assets created

1. 2 Public subnets for load balancers in 2 availability zones

2. 2 private subnets for ec2 instances in 2 availability zones

3. 2 private subnets for rds in 2 availability zones

4. Routes of all the private and public subnets for ec2 and loadbalancers are attached to NAT and Internet Gateway respectively

5. Create EKS cluster with fargate profile, node group, pod identity association

6. Security Groups:

    i. public - ingress and egress to port 80 and 443 from everywhere

    ii. private - ingress and egress to port 80 and 443 from everywhere
