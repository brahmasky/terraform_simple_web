# ============
# Create VPC
# ============
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "${var.web_server_namespace}-vpc-${terraform.workspace}"
  }
}


# ============
# Create one public subnet per each AZ
# ============

# Retrieve availability zones
data "aws_availability_zones" "available" {
  state = "available"
}
resource "aws_subnet" "public_subnet" {
  for_each = toset(data.aws_availability_zones.available.names)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidr_blocks[each.key].public_subnet_cidr_block
  availability_zone = each.value

  tags = {
    Name = "public-subnet-${terraform.workspace}-${substr(each.value, -2, -1)}"
  }
}


# ============
# Create one private subnets per each AZ
# ============
resource "aws_subnet" "private_subnet" {
  for_each = toset(data.aws_availability_zones.available.names)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidr_blocks[each.key].private_subnet_cidr_block
  availability_zone = each.value

  tags = {
    Name = "private-subnet-${terraform.workspace}-${substr(each.value, -2, -1)}"
  }
}


# ============
# Create internet gateway to allow communications with internet
# ============
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "internet-gateway-${terraform.workspace}"
  }
}


# ============
# Create one EIP and one NAT Gateway for each public subnet
# ============
resource "aws_eip" "nat_ip" {
  for_each = aws_subnet.public_subnet

  vpc = true
  tags = {
    Name = "nat-ip-${terraform.workspace}-${substr(each.key, -2, -1)}"
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  for_each = aws_subnet.public_subnet

  subnet_id     = each.value.id
  allocation_id = aws_eip.nat_ip[each.key].id

  depends_on = [aws_internet_gateway.internet_gateway]

  tags = {
    Name = "nat-gateway-${terraform.workspace}-${substr(each.key, -2, -1)}"
  }
}


# ============
# Route Table with route and association for public subnets
# ============
resource "aws_route_table" "public_route_table" {
  for_each = aws_subnet.public_subnet
  vpc_id   = aws_vpc.main.id

  tags = {
    Name = "public-route-table-${terraform.workspace}-${substr(each.key, -2, -1)}"
  }
}

resource "aws_route_table_association" "public_route_table_association" {
  for_each = aws_subnet.public_subnet

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_route_table[each.key].id
}

resource "aws_route" "public_internet_route" {
  for_each = aws_subnet.public_subnet

  route_table_id         = aws_route_table.public_route_table[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id

  timeouts {
    create = "5m"
  }
}


# ============
# Route Table with rules and association for private subnets
# ============
resource "aws_route_table" "private_route_table" {
  for_each = aws_nat_gateway.nat_gateway

  vpc_id = aws_vpc.main.id

  tags = {
    Name = "private-route-table-${terraform.workspace}-${substr(each.key, -2, -1)}"
  }
}

resource "aws_route_table_association" "private_route_table_association" {
  for_each = aws_subnet.private_subnet

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_route_table[each.key].id
}

resource "aws_route" "nat_gateway" {
  for_each = aws_nat_gateway.nat_gateway

  route_table_id         = aws_route_table.private_route_table[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = each.value.id

  timeouts {
    create = "5m"
  }
}


# ============
# Security group and rules for load balancer
# ============
resource "aws_security_group" "web_server_alb_sg" {
  name        = "${var.web_server_namespace}-alb-sg-${terraform.workspace}"
  description = "Security group for ALB with inline rules that allows HTTP ingress from internet and HTTP egress to private subnets"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [for subnet in aws_subnet.private_subnet : subnet.cidr_block]
  }
  tags = {
    Name = "${var.web_server_namespace}-alb-sg-${terraform.workspace}"
  }
}


# ============
# Security group and rules for web servers
# ============
resource "aws_security_group" "web_server_sg" {
  name        = "${var.web_server_namespace}-sg-${terraform.workspace}"
  description = "Security group for Web Server with inline rules that allows HTTP ingress from ALB and HTTP/HTTPS egress for package installation"
  vpc_id      = aws_vpc.main.id
  # allow ingress 80 from ALB and bastion host
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.web_server_alb_sg.id, aws_security_group.bastion_host_sg.id]
  }
  # allow for SSH access from bastion host
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_host_sg.id]
  }
  #  HTTP
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #  HTTPS
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.web_server_namespace}-sg-${terraform.workspace}"
  }
}

# ============
# Security group and rules for bastion host
# ============

# Retrieve public IP with terraform http provider
data "http" "my_public_ip" {
  url = "https://ifconfig.me"
}

resource "aws_security_group" "bastion_host_sg" {
  name   = "bastion-host-sg-${terraform.workspace}"
  vpc_id = aws_vpc.main.id

  # restrict SSH access to the laptop executing the terraform templates
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${data.http.my_public_ip.body}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "bastion-host-sg-${terraform.workspace}"
  }
}