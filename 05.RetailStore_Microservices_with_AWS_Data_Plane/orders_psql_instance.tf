# Create RDS PSQL Instance

resource "aws_db_instance" "psql" {
  identifier = var.orders_psql_identifier
  engine = var.orders_psql_engine
  engine_version = var.orders_psql_engine_version
  instance_class = var.orders_psql_instance_class
  allocated_storage = var.orders_psql_allocated_storage
  max_allocated_storage = var.orders_psql_max_allocated_storage
  db_subnet_group_name = aws_db_subnet_group.psql_subnet_group.name
  vpc_security_group_ids = [aws_security_group.psql_sg.id]

  db_name = var.orders_psql_db_name
  username = local.retailstore_secret_json.username
  password = local.retailstore_secret_json.password
  port = 5432

  multi_az = false
  storage_encrypted = true
  publicly_accessible = false
  skip_final_snapshot = true

  backup_retention_period = 1
  deletion_protection = false

  tags = var.tags
}

output "orders_psql_endpoint" {
  value = aws_db_instance.psql.endpoint
}

output "orders_psql_db_name" {
  value = aws_db_instance.psql.db_name
}