variable "vpc_id" {
    type = string
}



variable "ec2_sg_tags" {
  type = map(string)
}

variable "ingress_ports" {
  type = list(number)
}