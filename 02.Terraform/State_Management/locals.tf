locals {
  Name = "tfstate-${var.env_name}-${random_string.name.result}"
}