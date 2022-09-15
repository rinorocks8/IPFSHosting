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
      "export IPFS_PATH=/home/ubuntu/ipfs/data",
      "export AWS_ACCESS_KEY_ID=${var.AWS_ACCESS_KEY_ID}",
      "export AWS_SECRET_ACCESS_KEY=${var.AWS_SECRET_ACCESS_KEY}",
      "export AWS_DEFAULT_REGION=${var.aws_region}",
      "rm -r /home/ubuntu/files/*",
      "aws s3 cp s3://${aws_s3_bucket.ipfs_files.bucket} /home/ubuntu/files/ --recursive",
      //"sudo -E ipfs name publish --key=resume $(sudo -E ipfs add -r /home/ubuntu/files/* | awk '{print $2}')"
    ]
  }
}