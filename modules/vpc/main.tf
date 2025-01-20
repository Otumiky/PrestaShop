resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "public" {
  count                  = length(var.public_subnets)
  vpc_id                 = aws_vpc.main.id
  cidr_block             = var.public_subnets[count.index]
  availability_zone      = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.vpc_name}-public-${count.index + 1}"
  }
}

resource "aws_subnet" "private" {
  count                  = length(var.private_subnets)
  vpc_id                 = aws_vpc.main.id
  cidr_block             = var.private_subnets[count.index]
  availability_zone      = element(var.availability_zones, count.index)
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.vpc_name}-private-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.vpc_name}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
    tags = {
    Name = "${var.vpc_name}-nat-eip"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = element(aws_subnet.public[*].id, 0) # Use the first public subnet
  tags = {
    Name = "${var.vpc_name}-nat-gateway"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "${var.vpc_name}-private-rt"
  }
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

#security group for rds
resource "aws_security_group" "rds_sg" {
  name        = "${var.vpc_name}-rds-sg"
  description = "Security group for RDS"
  vpc_id      = aws_vpc.main.id
}

# RDS allows inbound traffic from EC2 security group
resource "aws_security_group_rule" "rds_inbound_from_ec2" {
  type        = "ingress"
  from_port   = 3306
  to_port     = 3306
  protocol    = "tcp"
  security_group_id = aws_security_group.rds_sg.id
  source_security_group_id = aws_security_group.ec2_sg.id
}

# RDS allows all outbound traffic
resource "aws_security_group_rule" "rds_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.rds_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}

#security group for ec2
resource "aws_security_group" "ec2_sg" {
  name        = "${var.vpc_name}-ec2-sg"
  description = "Security group for EC2 instances"
  vpc_id      = aws_vpc.main.id
}

# EC2 allows inbound traffic from the internet (e.g., for HTTP)
resource "aws_security_group_rule" "ec2_inbound_http" {
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  security_group_id = aws_security_group.ec2_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}

# Allow inbound HTTPS traffic from anywhere (internet)
resource "aws_security_group_rule" "ec2_inbound_https" {
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  security_group_id = aws_security_group.ec2_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}

# Allow inbound SSH traffic from a specific IP range (e.g., your IP) for secure access
resource "aws_security_group_rule" "ec2_inbound_ssh" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  security_group_id = aws_security_group.ec2_sg.id
  cidr_blocks       = ["0.0.0.0/0"]  # Replace with your IP address or range
}
# EC2 allows inbound traffic from RDS
resource "aws_security_group_rule" "ec2_inbound_from_rds" {
  type        = "ingress"
  from_port   = 3306
  to_port     = 3306
  protocol    = "tcp"
  security_group_id = aws_security_group.ec2_sg.id
  source_security_group_id = aws_security_group.rds_sg.id
}

# EC2 allows all outbound traffic
resource "aws_security_group_rule" "ec2_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.ec2_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}