# ----------------------------------------------------------------------
# AMI Selection
# ----------------------------------------------------------------------
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# ----------------------------------------------------------------------
# EC2 Instance
# ----------------------------------------------------------------------
data "cloudinit_config" "ipfs_bootstrap" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content      = local.cloud_config_config
  }

}

resource "aws_instance" "ipfs_host" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  security_groups = [aws_security_group.allow_ssh.id, aws_security_group.allow_ipfs.id]
  subnet_id       = aws_subnet.ipfs_subnet.id
  key_name        = "ec2-deployer-key-pair"

  tags = {
    Name        = "ipfs_host"
    "Terraform" = "Yes"
  }

  user_data = data.cloudinit_config.ipfs_bootstrap.rendered
}

resource "aws_key_pair" "deployer" {
  key_name   = "ec2-deployer-key-pair"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC6bKCn+Pp0BjO9icVNkIEiHzjThv3uM2yHwWKu33TJLxiz9ep6yJvFn8TDuvzLJe54WCgT527cYqo9RGuHjFVgCDCVFGZsASEnt3zhMlSkhBe/29V6Mplx7YNjT0Y4FgoGdaBK/D0+wGuh6/30AjdnQ6qlsAOPJBgAN+lgBtBLmetqAElTN9mxNDwDoSXlbJtMeDn/4woJyMXgaszVnt+44fK3uGFxlwJAHTEpYVY18G0ThIUfB6ZyCrL6KSEzpSy9jGhV39/aRQnidl+ZTLFVVXJsQXa5Zi8fTJR4wvTvIMZaou5+T+HvpQyYN2uxg+jbuNxdqqTQNx9dykfcVB7J/kjW3aAk0fiYfeOTwTYPuAZfmlAlBdlLgIfhFA75KSYeT+afXRSQ7RZa7zhsPjuwMA6gVqizgNWm7dIDhi9rH/LgetEt4GrSaFj29jH7/k3ooe5ojIw3jysWSrN6rploMGjPt5mNZOl7sZqi0XbgaPE3AvWofQqDPG45IIfe/p0= ryanr@DESKTOP-K6VV99C"
}