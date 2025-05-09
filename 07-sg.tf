// Security group for Load Balancer in public subnet, allow traffic to ports 80 and 443



resource "aws_security_group" "sg_loadbalancer" {
  name        = "LoadBalancer"
  description = "Security Group for public Load Balancer"
  vpc_id      = aws_vpc.main.id
  tags = {
    name = "loadbalancer"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow__ipv4" {
  security_group_id = aws_security_group.sg_loadbalancer.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.sg_loadbalancer.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}
# resource "aws_security_group_rule" "http_lb" {
#   type              = "ingress"
#   from_port         = 80
#   to_port           = 80
#   protocol          = "tcp"
#   security_group_id = aws_security_group.sg_loadbalancer.id
#   cidr_blocks       = [aws_vpc.main.cidr_block, "0.0.0.0/0"]
# }

# resource "aws_security_group_rule" "lb_http" {
#   type              = "egress"
#   from_port         = 80
#   to_port           = 80
#   protocol          = "tcp"
#   security_group_id = aws_security_group.sg_loadbalancer.id
#   cidr_blocks       = [aws_vpc.main.cidr_block, "0.0.0.0/0"]
# }

# resource "aws_security_group_rule" "https_lb" {
#   type              = "ingress"
#   from_port         = 443
#   to_port           = 443
#   protocol          = "tcp"
#   security_group_id = aws_security_group.sg_loadbalancer.id
#   cidr_blocks       = [aws_vpc.main.cidr_block, "0.0.0.0/0"]
# }

# resource "aws_security_group_rule" "lb_https" {
#   type              = "egress"
#   from_port         = 443
#   to_port           = 443
#   protocol          = "tcp"
#   security_group_id = aws_security_group.sg_loadbalancer.id
#   cidr_blocks       = [aws_vpc.main.cidr_block, "0.0.0.0/0"]
# }

# resource "aws_security_group_rule" "ssh_lb" {
#   type              = "ingress"
#   from_port         = 22
#   to_port           = 22
#   protocol          = "tcp"
#   security_group_id = aws_security_group.sg_loadbalancer.id
#   cidr_blocks       = [aws_vpc.main.cidr_block, "0.0.0.0/0"]
# }

# resource "aws_security_group_rule" "lb_ssh" {
#   type              = "egress"
#   from_port         = 22
#   to_port           = 22
#   protocol          = "tcp"
#   security_group_id = aws_security_group.sg_loadbalancer.id
#   cidr_blocks       = [aws_vpc.main.cidr_block, "0.0.0.0/0"]
# }



// Security group for private instances ingress and egress from everywhere on port 80 and 443, ingress and egress from rds security group
# resource "aws_security_group" "sg_private" {
#   name        = "sg_private"
#   description = "Security group for private instances"
#   vpc_id      = aws_vpc.main.id
#   depends_on = [ aws_security_group.sg_loadbalancer ]
# }

# // Allow traffic from Load Balancer to private instances
# resource "aws_security_group_rule" "lb_to_private_http" {
#   type              = "ingress"
#   from_port         = 80
#   to_port           = 80
#   protocol          = "tcp"
#   security_group_id = aws_security_group.sg_private.id
#   cidr_blocks = ["0.0.0.0/0"]
#   depends_on = [ aws_security_group.sg_private ]
# }

# resource "aws_security_group_rule" "private_http_to_lb" {
#   type              = "egress"
#   from_port         = 80
#   to_port           = 80
#   protocol          = "tcp"
#   security_group_id = aws_security_group.sg_private.id
#   cidr_blocks = ["0.0.0.0/0"]
#   depends_on = [ aws_security_group.sg_private ]
# }

# resource "aws_security_group_rule" "lb_to_private_https" {
#   type              = "ingress"
#   from_port         = 443
#   to_port           = 443
#   protocol          = "tcp"
#   security_group_id = aws_security_group.sg_private.id
#   cidr_blocks = ["0.0.0.0/0"]
#   depends_on = [ aws_security_group.sg_private ]
# }

# resource "aws_security_group_rule" "private_https_to_lb" {
#   type              = "egress"
#   from_port         = 443
#   to_port           = 443
#   protocol          = "tcp"
#   security_group_id = aws_security_group.sg_private.id
#   cidr_blocks = ["0.0.0.0/0"]
#   depends_on = [ aws_security_group.sg_private ]
# }

# resource "aws_security_group_rule" "lb_to_private_envoy_proxy" {
#   type                     = "ingress"
#   from_port                = 8080
#   to_port                  = 8080
#   protocol                 = "tcp"
#   security_group_id        = aws_security_group.sg_private.id
#   source_security_group_id = aws_security_group.sg_loadbalancer.id
#   depends_on = [ aws_security_group.sg_private ]
# }

# resource "aws_security_group_rule" "private_envoy_proxy_to_lb" {
#   type                     = "egress"
#   from_port                = 8080
#   to_port                  = 8080
#   protocol                 = "tcp"
#   security_group_id        = aws_security_group.sg_private.id
#   source_security_group_id = aws_security_group.sg_loadbalancer.id
#   depends_on = [ aws_security_group.sg_private ]
# }

# resource "aws_security_group_rule" "lb_to_private_prometheus" {
#   type                     = "ingress"
#   from_port                = 9090
#   to_port                  = 9090
#   protocol                 = "tcp"
#   security_group_id        = aws_security_group.sg_private.id
#   source_security_group_id = aws_security_group.sg_loadbalancer.id
#   depends_on = [ aws_security_group.sg_private ]
# }

# resource "aws_security_group_rule" "private_prometheus_to_lb" {
#   type                     = "egress"
#   from_port                = 9090
#   to_port                  = 9090
#   protocol                 = "tcp"
#   security_group_id        = aws_security_group.sg_private.id
#   source_security_group_id = aws_security_group.sg_loadbalancer.id
#   depends_on = [ aws_security_group.sg_private ]
# }

# resource "aws_security_group_rule" "lb_to_private_grafana_dsh" {
#   type                     = "ingress"
#   from_port                = 3000
#   to_port                  = 3000
#   protocol                 = "tcp"
#   security_group_id        = aws_security_group.sg_private.id
#   source_security_group_id = aws_security_group.sg_loadbalancer.id
#   depends_on = [ aws_security_group.sg_private ]
# }

# resource "aws_security_group_rule" "private_grafana_dsh_to_lb" {
#   type                     = "egress"
#   from_port                = 3000
#   to_port                  = 3000
#   protocol                 = "tcp"
#   security_group_id        = aws_security_group.sg_private.id
#   source_security_group_id = aws_security_group.sg_loadbalancer.id
#   depends_on = [ aws_security_group.sg_private ]
# }