# ----------------------------------------------------------------------
# CloudInit Config - When a new instance is created, this sends the
#   files to instance and runs the bootstrap script.
# ----------------------------------------------------------------------
locals {
  cloud_config_config = <<-END
    #cloud-config
    ${jsonencode({
  write_files = [
    {
      path        = "/lib/systemd/system/ipfs.service"
      permissions = "644"
      owner       = "root:root"
      encoding    = "b64"
      content     = filebase64("./libs/ipfs.service")
    },
    {
      path        = "/usr/local/bin/bootstrap.sh"
      permissions = "644"
      owner       = "root:root"
      encoding    = "b64"
      content     = filebase64("./libs/bootstrap.sh")
    }
  ],
  runcmd = [
    "sudo bash /usr/local/bin/bootstrap.sh"
  ]
})}
  END
}