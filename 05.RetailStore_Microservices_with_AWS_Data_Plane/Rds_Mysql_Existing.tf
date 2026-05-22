# data "aws_db_subnet_group" "existing_rds_subnet_group" {
#   name = "vanbor-rds-private-subnet"
# }

# # db_subnet_group_name = data.aws_db_subnet_group.existing_rds_subnet_group.name
# output "db_subnet_group_name" {
#     value = data.aws_db_subnet_group.existing_rds_subnet_group.name
# }

# # Use existing RDS MySQL

# data "aws_db_instance" "catalog_rds" {
#   db_instance_identifier = "vanbor-mydb3"
# }

# # Create Own Username and Password in this existing RDS

# resource "mysql_user" "bhavin_user" {

#   user               = local.retailstore_secret_json.username
#   host               = "%"
#   plaintext_password = local.retailstore_secret_json.password
# }

# resource "mysql_grant" "catalogdb_grant" {

#   user       = mysql_user.bhavin_user.user
#   host       = mysql_user.bhavin_user.host

#   database   = "catalogdb"

#   privileges = [
#     "ALL"
#   ]
# }

# # Use SecretsManager

# # Use existing AWS Secrets Manager Secret

# data "aws_secretsmanager_secret" "secret" {
#     name = "Bhavin_EKS_catalog-db-secret"
# }

# data "aws_secretsmanager_secret_version" "secret_value" {
#     secret_id = data.aws_secretsmanager_secret.secret.id
# }

# locals {
#   retailstore_secret_json = jsondecode(data.aws_secretsmanager_secret_version.secret_value.secret_string)
# }


# # MySQL new username and password from secretsmanager

# output "secret_username" {
#     value = local.retailstore_secret_json.MYSQL_USER
#     sensitive = true
# }

# output "secret_passwd" {
#     value = local.retailstore_secret_json.MYSQL_PASSWORD
#     sensitive = true
# }

# output "default_secret_username" {
#   value = local.retailstore_secret_json.username
#   sensitive = true
# }

# output "default_secret_passwd" {
#   value = local.retailstore_secret_json.password
#   sensitive = true
# }

# # Create RDS SG

# resource "aws_security_group" "rds_pvt_sg" {
#   name = "${local.eks_cluster_name}-rds-pvt-sg"
#   vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id

#   ingress {
#     from_port = 3306
#     to_port = 3306
#     protocol = "tcp"
#     # security_groups = [data.terraform_remote_state.eks.outputs.eks_cluster_security_group_id]
#     # security_groups = [data.terraform_remote_state.eks.outputs.eks_cluster_security_group_id]
#     security_groups = [data.terraform_remote_state.eks.outputs.eks_cluster_security_group_id]
#   }

#   egress {
#     from_port = 0
#     to_port = 0
#     protocol = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = var.tags
# }