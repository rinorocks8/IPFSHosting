# ----------------------------------------------------------------------
# VPC
# ----------------------------------------------------------------------
resource "aws_vpc" "ipfs_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "ipfs_vpc"
  }
}

# ----------------------------------------------------------------------
# Subnet
# ----------------------------------------------------------------------
resource "aws_subnet" "ipfs_subnet" {
  vpc_id            = aws_vpc.ipfs_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.ipfs_vpc.cidr_block, 3, 1)
  availability_zone = "us-east-1a"
}

resource "aws_route_table" "ipfs_route_table" {
  vpc_id = aws_vpc.ipfs_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ipfs_gw.id
  }
  tags = {
    Name = "ipfs_route_table"
  }
}

resource "aws_route_table_association" "subnet-association" {
  subnet_id      = aws_subnet.ipfs_subnet.id
  route_table_id = aws_route_table.ipfs_route_table.id
}

# ----------------------------------------------------------------------
# Security
# ----------------------------------------------------------------------
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.ipfs_vpc.id

  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
  }

  // Removes the default rule
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_ipfs" {
  name        = "allow_ipfs"
  description = "Allow ipfs traffic"
  vpc_id      = aws_vpc.ipfs_vpc.id

  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"
  }

  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 4001
    to_port   = 4002
    protocol  = "tcp"
  }

  // Removes the default rule
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ----------------------------------------------------------------------
# EIP - Attaches Public IP to instance
# ----------------------------------------------------------------------
resource "aws_eip" "ipfs_vpc_ip" {
  instance = aws_instance.ipfs_host.id
  vpc      = true
}

# ----------------------------------------------------------------------
# Gateway - Routes Traffic
# ----------------------------------------------------------------------
resource "aws_internet_gateway" "ipfs_gw" {
  vpc_id = aws_vpc.ipfs_vpc.id
  tags = {
    Name = "ipfs_gw"
  }
}