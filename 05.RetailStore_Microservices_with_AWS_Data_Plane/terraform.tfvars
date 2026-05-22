aws_region = "ap-south-1"

environment_name = "test"

catalodb_engine = "mysql"
catalogdb_allocated_storage = 20
catalogdb_db_name = "catalogdb"
catalogdb_engine_version = "8.0"
catalogdb_identifier = "mydb3-bhavin"
catalogdb_instance_class = "db.t3.micro"
# catalogdb_pawsswd = 
# catalogdb_username = 
# catalogdb_subnet_group_name = 

checkout_redis_engine = "redis"
checkout_redis_engine_version = "7.1"
checkout_redis_node_type = "cache.t3.micro"
checkout_redis_num_cache_nodes = 1

orders_psql_identifier = "orders-postgresql-db"
orders_psql_engine = "postgres"
orders_psql_engine_version = "17.6"
orders_psql_instance_class = "db.t4g.micro"
orders_psql_allocated_storage = 20
orders_psql_max_allocated_storage = 100
orders_psql_db_name = "ordersdb"

tags = {
    Department   = "PES_IA"
    Owner        = "bhavin.bhavsar@einfochips.com"
    End_Date     = "20 May 2026"
    Project_Name = "EIC_Internal"
    DM           = "Sachin.Shah1@einfochips.com"

}
