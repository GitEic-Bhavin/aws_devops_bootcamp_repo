data "aws_vpc" "default" {
  id = "vpc-05a1f31c59ceea119"
}

data "aws_subnet" "pub_sub_1a" {
    filter {
      name = "vpc-id"
      values = [data.aws_vpc.default.id]
    }
    filter {
      name = "cidr-block"
      values = ["192.168.2.0/24"]
    }

}

data "aws_subnet" "pub_sub_1b" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name = "cidr-block"
    values = ["192.168.3.0/24"]
  }

}

output "vpc_id" {
  value = data.aws_vpc.default.id
}

# output "subnet_id" {
#   value = data.aws_subnets.default.ids[0]
# }

output "public_subnet_ids" {
  value = [
    data.aws_subnet.pub_sub_1a.id,
    data.aws_subnet.pub_sub_1b.id
  ]
}

