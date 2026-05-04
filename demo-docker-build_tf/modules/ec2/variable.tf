variable "ec2_tags" {
    type = map(string)
}

variable "instance_type" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "sg_id" {
  type = string
}

variable "mdatp_file_path" {
  type = string
}