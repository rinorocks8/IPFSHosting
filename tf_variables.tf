variable "AWS_DEFAULT_REGION" {
  default = "us-east-1"
}

variable "AWS_ACCESS_KEY_ID" {
  type = string
}

variable "AWS_SECRET_ACCESS_KEY" {
  type = string
}

variable "AWS_KMS_KEY" {
  type = string
}

variable "ssh_private_key" {
  type = string
}