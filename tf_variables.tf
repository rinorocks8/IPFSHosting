variable "TF_VAR_AWS_DEFAULT_REGION" {
  default = "us-east-1"
}

variable "TF_VAR_AWS_ACCESS_KEY_ID" {
  type = string
}

variable "TF_VAR_AWS_SECRET_ACCESS_KEY" {
  type = string
}

variable "ssh_private_key" {
  type = string
}