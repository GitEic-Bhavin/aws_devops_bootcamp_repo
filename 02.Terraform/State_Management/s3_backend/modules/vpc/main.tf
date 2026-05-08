# Use existing vpc , subnets, NAT and IGW, Route table

data "aws_vpc" "exist" {
  id = var.vpc_id
}

resource "aws_subnet" "public" {
  vpc_id                  = data.aws_vpc.exist.id
  # cidr_block              = "10.0.11.0/24"
  cidr_block = var.pub_sub_cidr_block
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  # tags = {
  #   Name = "BhavinBhavsar-01-pub-subnet"
  # }
  tags = var.pub_sub_name
}

resource "aws_subnet" "private" {
  vpc_id            = data.aws_vpc.exist.id
  # cidr_block        = "10.0.111.0/24"
  cidr_block = var.pvt_sub_cidr_block
  availability_zone = "ap-south-1a"

  # tags = {
  #   Name = "BhavinBhavsar-01-priv-subnet"
  # }
  tags = var.pvt_sub_name
}


output "aws_public_sub_id" {
  value = aws_subnet.public.id
}

output "aws_private_sub_id" {
  value = aws_subnet.private.id
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
    # values = ["Bootcamp-vpc-do-not-delete-nat"] # Replace with your NAT GW Name tag
    values = var.nat_gateway_name
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

output "ngw_id" {
  value = data.aws_nat_gateway.existing.id
}

locals {
  pub_rt_name  = "BhavinBhavsar-01-pub-rt"
  priv_rt_name = "BhavinBhavsar-01-priv-rt"
}

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
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}