# Load ami and use amazon linux ami

data "aws_ami" "amazonlinux" {
    most_recent = true
    owners = ["099720109477"]

    filter {
      name = "name"
      values = ["ubuntu/images/hvm-ssd/ubuntu-*-amd64-server-*"]
    }

    filter {
      name = "virtualization-type"
      values = ["hvm"]
    }

    filter {
        name   = "architecture"
        values = ["x86_64"]
    }

    filter {
        name   = "root-device-type"
        values = ["ebs"]
    }

}

locals {
  mdatp_onboarding = file(var.mdatp_file_path)
}

# create ec2

resource "aws_instance" "example" {
    ami = data.aws_ami.amazonlinux.id
    instance_type = var.instance_type

    subnet_id = var.subnet_id
    key_name               = aws_key_pair.main.key_name
    vpc_security_group_ids = [var.sg_id]

    associate_public_ip_address = true


    connection {
      type = "ssh"
      user = "ubuntu"
      private_key = tls_private_key.ec2_key.private_key_pem
      host = self.public_ip

    }

# Customize size of default ebs to 30 GB.
    root_block_device {
        volume_size           = 30
        volume_type           = "gp3"
        delete_on_termination = true
    }

    # Installing MDATP in ubuntu ec2 user data

    user_data = <<-USERDATA
                #!/bin/bash
                set -e

                apt-get update -y
                echo 'Installing docker'

                ${file("${path.module}/docker_install.sh")}

                # Install base packages
                apt-get update -y
                apt-get install -y curl libplist-utils gpg gnupg apt-transport-https

                # Add Microsoft repo (Ubuntu 22.04)
                echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/ubuntu/22.04/prod jammy main" \
                > /etc/apt/sources.list.d/microsoft-prod.list

                # Add Microsoft key
                curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /usr/share/keyrings/microsoft.gpg

                # Update repo
                apt-get update -y

                # Install MDATP
                apt-get install -y mdatp

                # Backup existing onboarding file (if exists)
                mkdir -p /etc/opt/microsoft/mdatp/managed
                if [ -f /etc/opt/microsoft/mdatp/managed/mdatp_onboard.json ]; then
                    mv /etc/opt/microsoft/mdatp/managed/mdatp_onboard.json \
                    /etc/opt/microsoft/mdatp/managed/mdatp_onboard.json_old
                fi

                # Create onboarding JSON
                cat <<'EOT' > /etc/opt/microsoft/mdatp/managed/mdatp_onboard.json
                ${local.mdatp_onboarding}
                EOT

                # Set permissions
                chmod 600 /etc/opt/microsoft/mdatp/managed/mdatp_onboard.json

                # Restart service
                systemctl restart mdatp

                # Enable real-time protection
                mdatp config real-time-protection --value enabled

                USERDATA

    tags = var.ec2_tags

}



# Create Pem

resource "tls_private_key" "ec2_key" {
    algorithm = "RSA"
    rsa_bits  = 4096
}

resource "aws_key_pair" "main" {
  key_name   = "${var.ec2_tags["Name"]}-key"
  public_key = tls_private_key.ec2_key.public_key_openssh
}

resource "local_file" "ssh_key" {
  filename        = "${aws_key_pair.main.key_name}.pem"
  content         = tls_private_key.ec2_key.private_key_pem
  file_permission = "0400"
}
