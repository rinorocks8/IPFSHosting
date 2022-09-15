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
      "rm -r /home/ubuntu/files/*",
      "aws s3 cp s3://$AWS_IPFS_BUCKET /home/ubuntu/files/ --recursive",
      "aws kms decrypt --key-id $AWS_KMS_KEY --ciphertext-blob fileb:///home/ubuntu/files/ipns_key.encrypted --output text --query Plaintext | base64 -di | sudo tee /home/ubuntu/ipfs/data/keystore/key_ojsxg5lnmu  > /dev/null",
      "sudo -E ipfs name publish --key=resume $(sudo -E ipfs add -r /home/ubuntu/files/*.pdf | awk '{print $2}')"
    ]
    environment = {
      IPFS_PATH             = "/home/ubuntu/ipfs/data"
      AWS_ACCESS_KEY_ID     = var.AWS_ACCESS_KEY_ID
      AWS_SECRET_ACCESS_KEY = var.AWS_SECRET_ACCESS_KEY
      AWS_DEFAULT_REGION    = var.aws_region
      AWS_IPFS_BUCKET       = aws_s3_bucket.ipfs_files.bucket
      AWS_KMS_KEY           = var.AWS_KMS_KEY
    }
  }
}