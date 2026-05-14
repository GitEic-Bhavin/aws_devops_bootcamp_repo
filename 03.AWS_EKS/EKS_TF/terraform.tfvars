aws_region = "ap-south-1"



cluster_name = "eksdemo_bhavin"
cluster_version = "1.31"

cluster_service_ipv4_cidr = null

cluster_endpoint_public_access = true
cluster_endpoint_public_access_cidrs = ["115.112.142.32/29", "182.76.141.104/29", "14.97.73.248/32", "13.206.112.105/32", "115.112.142.34/32", "14.97.73.251/32"]
# cluster_endpoint_public_access_cidrs = [ "0.0.0.0/0" ]

tags = {
    Department   = "PES_IA"
    Owner        = "bhavin.bhavsar@einfochips.com"
    End_Date     = "4 May 2026"
    Project_Name = "EIC_Internal"
    DM           = "Sachin.Shah1@einfochips.com"

}

environment_name = "test"

node_capacity_type = "ON_DEMAND"
node_instance_types =  ["t3.medium"]
node_root_disk_size = 25