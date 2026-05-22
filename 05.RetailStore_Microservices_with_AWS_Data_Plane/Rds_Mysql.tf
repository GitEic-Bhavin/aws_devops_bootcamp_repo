resource "aws_db_instance" "catalog_rds" {
  identifier = var.catalogdb_identifier
  engine = var.catalodb_engine
  engine_version = var.catalogdb_engine_version
  instance_class = var.catalogdb_instance_class
  allocated_storage = var.catalogdb_allocated_storage
  db_name = var.catalogdb_db_name
  username = local.retailstore_secret_json.username
  password = local.retailstore_secret_json.password
  db_subnet_group_name = aws_db_subnet_group.rds_pvt.name
  
  vpc_security_group_ids = [aws_security_group.rds_pvt_sg.id]
  
  skip_final_snapshot = true
  publicly_accessible = false
  delete_automated_backups = true
  multi_az = false
  backup_retention_period = 1

  tags = var.tags
}

# # Use existing AWS Secrets Manager Secret

data "aws_secretsmanager_secret" "secret" {
    name = "Bhavin_EKS_catalog-db-secret"
}

data "aws_secretsmanager_secret_version" "secret_value" {
    secret_id = data.aws_secretsmanager_secret.secret.id
}

locals {
  retailstore_secret_json = jsondecode(data.aws_secretsmanager_secret_version.secret_value.secret_string)
}

output "secret_username" {
  value = local.retailstore_secret_json.username
  sensitive = true
}

output "secret_passwd" {
  value = local.retailstore_secret_json.password
  sensitive = true
}

# # If you want to actually see the values just once (for validation), you can run:
# # terraform output -json | jq -r '.debug_retailstore_secret_username.value'
# # terraform output -json | jq -r '.debug_retailstore_secret_password.value'

# # Create RDS Pvt Subnet Group

resource "aws_db_subnet_group" "rds_pvt" {
  name = "${local.eks_cluster_name}-rds-pvt-subnets"
  subnet_ids = data.terraform_remote_state.vpc.outputs.aws_private_sub_id

  tags = var.tags

}

resource "aws_security_group" "rds_pvt_sg" {
  name = "${local.eks_cluster_name}-rds-pvt-sg"
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    # security_groups = [data.terraform_remote_state.eks.outputs.eks_cluster_security_group_id]
    security_groups = [data.terraform_remote_state.eks.outputs.eks_cluster_security_group_id]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}