variable "ec2_tags" {
    # type = object({
    #   Name = "Bhavin_ec2"
    #   Department = "PES_IA"
    #   Owner = "bhavin.bhavsar@einfochips.com"
    #   End_Date = "4 May 2026"
    #   Project_Name = "EIC_Internal"
    #   DM = "Sachin.Shah1@einfochips.com"
    # })
    type = map(string)
    default = {
        Name         = "Bhavin_ec2"
        Department   = "PES_IA"
        Owner        = "bhavin.bhavsar@einfochips.com"
        End_Date     = "4 May 2026"
        Project_Name = "EIC_Internal"
        DM           = "Sachin.Shah1@einfochips.com"
    }
}

variable "instance_type" {
  type = string
  default = "t2.medium"
}

# variable "subnet_id" {
  
# }

variable "ec2_sg_tags" {
#   type = object({
#     Name = "Bhavin_Ec2_SG"
#     Department = "PES_IA"
#       Owner = "bhavin.bhavsar@einfochips.com"
#       End_Date = "4 May 2026"
#       Project_Name = "EIC_Internal"
#       DM = "Sachin.Shah1@einfochips.com"
#   })
    type = map(string)
    default = {
        Name         = "Bhavin_ec2"
        Department   = "PES_IA"
        Owner        = "bhavin.bhavsar@einfochips.com"
        End_Date     = "4 May 2026"
        Project_Name = "EIC_Internal"
        DM           = "Sachin.Shah1@einfochips.com"
    }
}

variable "ingress_ports" {
  type = list(number)
  default = [22, 80, 8080]

}

variable "mdatp_file_path" {
  type = string
  default = "/home/einfochips/Downloads/ubuntu_20.04/mdatp_onboard.json"
}