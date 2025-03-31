data "aws_ami" "amazon_linux_ami" {
  most_recent = true
  owners      = ["self"]
  filter {
    name   = "name"
    values = ["amazon-linux-docker*"]
  }
}

data "aws_ami" "ubuntu_ami" {
  most_recent = true
  owners      = ["self"]
  filter {
    name   = "name"
    values = ["amazon-ubuntu-docker*"]
  }
}

data "aws_ami" "ansible_controller_ami" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.6*-x86_64"]
  }
}

# EC2 instances - Amazon Linux
resource "aws_instance" "amazon_linux_instances" {
  count         = 3
  ami           = data.aws_ami.amazon_linux_ami.id
  instance_type = "t2.micro"
  subnet_id     = module.vpc.private_subnets[0]
  vpc_security_group_ids = [aws_security_group.private_instances.id]
  key_name      = var.public_key

  tags = merge(
    var.resource_tags,
    {
      Name = "amazon-linux-ec2-${format("%02d", count.index + 1)}",
      OS   = "amazon"
    }
  )
}

# EC2 instances - Ubuntu
resource "aws_instance" "ubuntu_instances" {
  count         = 3
  ami           = data.aws_ami.ubuntu_ami.id
  instance_type = "t2.micro"
  subnet_id     = module.vpc.private_subnets[0]
  vpc_security_group_ids = [aws_security_group.private_instances.id]
  key_name      = var.public_key

  tags = merge(
    var.resource_tags,
    {
      Name = "ubuntu-ec2-${format("%02d", count.index + 1)}",
      OS   = "ubuntu"
    }
  )
}

# Ansible Controller
resource "aws_instance" "ansible_controller" {
  ami           = data.aws_ami.ansible_controller_ami.id
  instance_type = "t2.micro"
  subnet_id     = module.vpc.private_subnets[0]
  vpc_security_group_ids = [aws_security_group.private_instances.id]
  key_name      = var.public_key

  tags = merge(
    var.resource_tags,
    {
      Name = "ansible-controller",
      Role = "controller"
    }
  )

  user_data = <<-EOF
    #!/bin/bash
    dnf update -y
    dnf install -y ansible-core python3-pip
    pip3 install boto3
    EOF
}
