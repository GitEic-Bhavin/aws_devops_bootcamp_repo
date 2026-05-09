aws_region = "ap-south-1"

s3_remote_bucket_name = "bhavindemo-s3-tfstate-test-qde61"

s3_env_name_s3 = "test"

vpc_id = "vpc-02358ddc1cb955bcd"

pub_sub_cidr_block = "10.0.11.0/24"
pvt_sub_cidr_block = "10.0.111.0/24"

# nat_gateway_name = ["Bootcamp-vpc-do-not-delete-nat"]
nat_gateway_name = [ "Bhavin_NAT_Gateway" ]
# nat_gateway_name = [ "kalpesh-demo" ]

pub_sub_name = {
  Name = "BhavinBhavsar-01-pub-subnet"
}

pvt_sub_name = {
  Name = "BhavinBhavsar-01-priv-subnet"
}

tags = {
  Name         = "Bhavin_ec2"
  Department   = "PES_IA"
  Owner        = "bhavin.bhavsar@einfochips.com"
  End_Date     = "4 May 2026"
  Project_Name = "EIC_Internal"
  DM           = "Sachin.Shah1@einfochips.com"
}

subnet_newbits = 8

vpc_cidr = "10.0.0.0/16"