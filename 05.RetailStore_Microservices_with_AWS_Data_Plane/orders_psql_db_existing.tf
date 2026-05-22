# data "aws_db_instance" "psql" {

#   db_instance_identifier = "orders-postgres-db"
# }

# # Create new username and password to this psql rds db existing


# # data "aws_secretsmanager_secret" "secret" {
# #     name = "Bhavin_EKS_catalog-db-secret"
# # }

# # data "aws_secretsmanager_secret_version" "secret_value" {
# #     secret_id = data.aws_secretsmanager_secret.secret.id
# # }

# # locals {
# #   retailstore_secret_json = jsondecode(data.aws_secretsmanager_secret_version.secret_value.secret_string)
# # }

# resource "postgresql_role" "orders_user" {

#   name = local.retailstore_secret_json.MYSQL_USER

#   login = true

#   password = local.retailstore_secret_json.MYSQL_PASSWORD
# }

# # Grant permission to this user

# resource "postgresql_grant" "ordersdb_access" {

#   database = "ordersdb"

#   role = postgresql_role.orders_user.name

#   object_type = "database"

#   privileges = [
#     "ALL"
#   ]
# }

# # ---------------------------------------------------
# # Existing Shared Subnet Group
# # ---------------------------------------------------

# data "aws_db_subnet_group" "existing_psql_subnet_group" {

#   name = "boot-camp-dev-rds-postgresql-subnet-group"
# }


# # Create SG for RDS PSQL
# resource "aws_security_group" "psql_sg" {
#   name = "${local.eks_cluster_name}-psql-sg"
#   vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id

#   ingress {
#     from_port = 5432
#     to_port = 5432
#     protocol = "tcp"
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

# output "orders_psql_endpoint" {
#   value = data.aws_db_instance.psql.endpoint
# }

# output "orders_psql_db_name" {
#   value = data.aws_db_instance.psql.db_name
# }