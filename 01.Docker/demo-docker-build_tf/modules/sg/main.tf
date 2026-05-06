data "http" "my_public_ip" {
  url = "https://ipv4.icanhazip.com"
}

resource "aws_security_group" "ec2" {
    vpc_id = var.vpc_id
  

    dynamic "ingress" {
        for_each = var.ingress_ports
        content {
            from_port = ingress.value
            to_port = ingress.value
            protocol = "tcp"
            # cidr_blocks = ["${chomp(data.http.my_public_ip.response_body)}/32"]
            cidr_blocks = ["115.112.142.32/29", "182.76.141.104/29", "14.97.73.248/32"]
        }
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = var.ec2_sg_tags


}

output "sg_id" {
  value = aws_security_group.ec2.id
}