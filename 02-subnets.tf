# create private subnet for webserver instances with public ip disabled attach this to a NAT
resource "aws_subnet" "private-subnet" {
  for_each                = var.private_subnet_cidrs
  availability_zone       = each.value["az"]
  cidr_block              = each.value["cidr"]
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = false

  tags = {
    "Name" = "${var.basename}-private-subnet-${each.value["az"]}"
    "kubernetes.io/role/internal-elb"="1"
    "kubernetes.io/cluster/${var.eks_cluster}" = "owned"
  }
}

# create public subnet for loadbalancer with public ip enabled 
resource "aws_subnet" "public-subnet" {
  for_each                = var.public_subnet_cidrs
  availability_zone    = each.value["az"]
  cidr_block              = each.value["cidr"]
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.basename}-public-subnet-${each.value["az"]}"
    "kubernetes.io/role/elb"="1"
    "kubernetes.io/cluster/${var.eks_cluster}" = "owned"
  }
}