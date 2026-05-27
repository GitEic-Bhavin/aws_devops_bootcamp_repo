# Use existing vpc , subnets, NAT and IGW, Route table

data "aws_vpc" "exist" {
  id = var.vpc_id
}

# resource "aws_subnet" "public" {
#   vpc_id                  = data.aws_vpc.exist.id
#   # cidr_block              = "10.0.11.0/24"
#   cidr_block = var.pub_sub_cidr_block
#   availability_zone       = "ap-south-1a"
#   map_public_ip_on_launch = true

#   # tags = {
#   #   Name = "BhavinBhavsar-01-pub-subnet"
#   # }
#   tags = var.pub_sub_name
# }

# resource "aws_subnet" "private" {
#   vpc_id            = data.aws_vpc.exist.id
#   # cidr_block        = "10.0.111.0/24"
#   cidr_block = var.pvt_sub_cidr_block
#   availability_zone = "ap-south-1a"

#   # tags = {
#   #   Name = "BhavinBhavsar-01-priv-subnet"
#   # }
#   tags = var.pvt_sub_name
# }

resource "aws_subnet" "public" {
  for_each = { for idx, az in local.azs : az => local.public_subnets[idx] }
  vpc_id = data.aws_vpc.exist.id
  cidr_block = each.value
  availability_zone = each.key
  tags = merge(var.tags, {
    Name = "BhavinBhavsar-pub-sub-${each.key}-${var.environment_name}"
  })
}


resource "aws_subnet" "private" {
  for_each = { for idx, az in local.azs : az => local.private_subnets[idx] }
  vpc_id            = data.aws_vpc.exist.id
  cidr_block        = each.value
  availability_zone = each.key
  tags = merge(var.tags, {
    Name = "${var.environment_name}-Bhavin-private-subnet--${each.key}"
  })
}

output "aws_public_sub_id" {
  value = [ for s in aws_subnet.public : s.id ]
}

output "aws_private_sub_id" {
  value = [ for s in aws_subnet.private : s.id ]
}

data "aws_internet_gateway" "existing" {
  filter {
    name   = "attachment.vpc-id"
    values = [data.aws_vpc.exist.id]
  }
}

output "igw_name" {
  value = data.aws_internet_gateway.existing.attachments
}

data "aws_nat_gateway" "existing" {
  filter {
    name   = "tag:Name"
    # values = ["Bhavin_NAT_Gateway"] # Replace with your NAT GW Name tag
    values = var.nat_gateway_name
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}



# output "ngw_id" {
#   value = data.aws_nat_gateway.existing.id
# }

# locals {
#   pub_rt_name  = "BhavinBhavsar-01-pub-rt"
#   priv_rt_name = "BhavinBhavsar-01-priv-rt"
# }

resource "aws_route_table" "public" {
  vpc_id = data.aws_vpc.exist.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_internet_gateway.existing.id

  }

  tags = {
    Name = local.pub_rt_name
  }
}


resource "aws_route_table" "private" {
  vpc_id = data.aws_vpc.exist.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = data.aws_nat_gateway.existing.id
  }

  tags = {
    Name = local.priv_rt_name
  }

}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {

  for_each = aws_subnet.private
  subnet_id = each.value.id
  route_table_id = aws_route_table.private.id
  # subnet_id      = aws_subnet.private.id
  # route_table_id = aws_route_table.private.id
}

output "vpc_id" {
  value = data.aws_vpc.exist.id
}