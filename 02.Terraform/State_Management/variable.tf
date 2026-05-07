variable "s3_tags" {
  type = map(string)
#   default = {
#     Name = "tfstate-${var.env_name}-${random_string.name.result}"
#     Envrionment = "test"
#     Project_Name = "Internal"
#     End_Date = "7 May 2026"
#     Owner = "bhavin.bhavsar@eifnochips.com"
#     DM = "Sachin.Shah1@einfochips.com"
#   }
}

variable "env_name" {
  type = string
}