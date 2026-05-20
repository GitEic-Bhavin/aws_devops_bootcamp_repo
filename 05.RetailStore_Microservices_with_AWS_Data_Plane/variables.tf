variable "aws_region" {
  type = string
  default = "ap-south-1"
}

variable "tags" {
  type = map(string)
}

variable "environment_name" {
  type = string
}

variable "catalogdb_identifier" {
  
}
variable "catalodb_engine" {
  
}

variable "catalogdb_db_name" {
  
}

variable "catalogdb_allocated_storage" {
  
}
variable "catalogdb_engine_version" {
  
}
variable "catalogdb_instance_class" {
  
}
# variable "catalogdb_subnet_group_name" {
  
# }
# variable "catalogdb_username" {
  
# }

# variable "catalogdb_pawsswd" {
  
# }

variable "checkout_redis_engine" {
  type = string
}
variable "checkout_redis_engine_version" {
  type = string
}
variable "checkout_redis_node_type" {
  type = string
}
variable "checkout_redis_num_cache_nodes" {
  type = number
}


variable "orders_psql_identifier" {
  type = string
}
variable "orders_psql_engine" {
  type = string
}
variable "orders_psql_engine_version" {
  type = string
}
variable "orders_psql_instance_class" {
  type = string
}
variable "orders_psql_allocated_storage" {
  type = number
}
variable "orders_psql_max_allocated_storage" {
  type = number
}
variable "orders_psql_db_name" {
  type = string
}