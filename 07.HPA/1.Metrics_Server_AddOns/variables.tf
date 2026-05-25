variable "aws_region" {
  type = string
  default = "ap-south-1"
}

variable "environment_name" {
  type = string
  default = "test"
}

variable "tags" {
  type = map(string)
  default = {
    Department   = "PES_IA"
    Owner        = "bhavin.bhavsar@einfochips.com"
    End_Date     = "4 May 2026"
    Project_Name = "EIC_Internal"
    DM           = "Sachin.Shah1@einfochips.com"
  }
}