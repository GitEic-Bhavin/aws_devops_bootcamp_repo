module "vpc" {
    source = "./modules/vpc"
    
  
}

module "ec2" {
    source = "./modules/ec2"
    ec2_tags = var.ec2_tags
    instance_type = var.instance_type
    subnet_id = module.vpc.subnet_id
    sg_id = module.sg.sg_id
    mdatp_file_path = var.mdatp_file_path
}

module "sg" {
    source = "./modules/sg"
    vpc_id = module.vpc.vpc_id

    ec2_sg_tags = var.ec2_sg_tags
    ingress_ports = var.ingress_ports
    
}