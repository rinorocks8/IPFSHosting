# ----------------------------------------------------------------------
# S3 Bucket to Store Files to Host
# ----------------------------------------------------------------------
resource "aws_s3_bucket" "ipfs_files" {
  depends_on = [
    aws_instance.ipfs_host
  ]
  bucket = "ipfs-files-bucket"
}

resource "aws_s3_bucket_object" "object" {
  for_each = fileset("files/", "**/*")
  key      = replace(each.value, "files/", "")
  source   = "files/${each.value}"
  bucket   = aws_s3_bucket.ipfs_files.id
  etag     = filemd5("files/${each.value}")
}

# ----------------------------------------------------------------------
# SSH Provisioner - Updates files on IPFS
# ----------------------------------------------------------------------

resource "null_resource" "publish_ipfs" {
  depends_on = [
    aws_s3_bucket.ipfs_files,
    aws_s3_bucket_object.object,
    aws_instance.ipfs_host,
    aws_eip.ipfs_vpc_ip,
    aws_internet_gateway.ipfs_gw
  ]

  triggers = {
    always_run = timestamp()
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = aws_eip.ipfs_vpc_ip.public_ip
    private_key = base64decode(var.ssh_private_key)
  }

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait",
      "echo 'Setting Env Variables'",
      "stty -echo",
      "export IPFS_PATH=/home/ubuntu/ipfs/data",
      "export AWS_ACCESS_KEY_ID=${nonsensitive(var.AWS_ACCESS_KEY_ID)}",
      "export AWS_SECRET_ACCESS_KEY=${nonsensitive(var.AWS_SECRET_ACCESS_KEY)}",
      "export AWS_KMS_KEY=${nonsensitive(var.AWS_KMS_KEY)}",
      "export AWS_DEFAULT_REGION=${var.AWS_DEFAULT_REGION}",
      "stty echo",
      "rm -r /home/ubuntu/files/*",
      "aws s3 cp s3://${aws_s3_bucket.ipfs_files.bucket} /home/ubuntu/files/ --recursive",
      "aws kms decrypt --key-id $AWS_KMS_KEY --ciphertext-blob fileb:///home/ubuntu/files/ipns_key.encrypted --output text --query Plaintext | base64 -di | sudo tee /home/ubuntu/ipfs/data/keystore/key_ojsxg5lnmu  > /dev/null",
      "sudo -E ipfs name publish --key=resume $(sudo -E ipfs add -r /home/ubuntu/files/*.pdf | awk '{print $2}')"
    ]
  }
}