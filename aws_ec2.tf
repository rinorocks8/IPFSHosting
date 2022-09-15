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

  vpc_security_group_ids = [aws_security_group.allow_ssh.id, aws_security_group.allow_ipfs.id]
  subnet_id              = aws_subnet.ipfs_subnet.id
  key_name               = "ec2-deployer-key-pair"

  tags = {
    Name        = "ipfs_host"
    "Terraform" = "Yes"
  }

  user_data = data.cloudinit_config.ipfs_bootstrap.rendered
}

resource "aws_key_pair" "deployer" {
  key_name   = "ec2-deployer-key-pair"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCZTsFTKhd4Fmp+gRJ/MSNC5Dq1JiQJFnY4tJvFNYh2iS4/m4SUUbuJBqYhwUTOTRmEsA0LBM65QB9DHnXosRqcfHRIp+2ojaEHhTFTEzLEo7pIK/rIPVslZ5AoGUrP7s7OanIh6gDpyOiJS1EjjeSEETjPajwFY7B7clpxR2g0oAut57hMdjR8PcaAUiWwJebBG+CRHZW/L9dvoAH8tymkeqN0TGqC4BthL8/xeTAaOoT/MhOK11Evx3bmGB/xJyTNpzIKpB+ockLjLfnCp7RD8navvzlXGTnY1BTGVgCnHA7e8In8jzRPjLGapqdE2NGSgooRiqQBxS+tQVKmpH+zZ1gLj3DPCbOr+M4uhdjEHz1MR4ynB5quynhvRjNecCgJ7tnKFCLxzCSgKLASlTa5Hf3QL7CLIn/zvHD1GEBNZ/Ilm79TQwUEj5X1D46eF+gAc1YMLnGsR1NzN3t8nouaBoQscHiRM1AAV9mIo/+Xxjn4w+fC4PKFTjyEtXVG86c= ryanr@DESKTOP-K6VV99C"
}