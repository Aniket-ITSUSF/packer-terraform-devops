# Get your public IP address for SSH access
data "http" "my_ip" {
  url = "https://api.ipify.org?format=text" // fetch your ip address
}

# Security group for the bastion host
resource "aws_security_group" "bastion_sg" {
  vpc_id      = module.vpc.vpc_id
  name        = "bastion-sg"
  description = "Security group for the bastion host"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${data.http.my_ip.response_body}/32"]
  }

  tags = merge(
    var.resource_tags,
    { Name = "bastion-sg" }
  )
}

# Bastion host in public subnet
resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.ansible_controller_ami.id # Using the same Amazon Linux AMI
  instance_type               = "t2.micro"
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  key_name                    = var.public_key # Using the ami-pair key
  associate_public_ip_address = true

  tags = merge(
    var.resource_tags,
    { Name = "bastion-host" }
  )
}

# Security group for private instances (modified)
resource "aws_security_group" "private_instances" {
  vpc_id      = module.vpc.vpc_id
  name        = "private-instances"
  description = "Security group for private subnet instances"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow SSH from bastion security group
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  # Allow internal communication within the security group
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    self            = true
  }

  tags = merge(
    var.resource_tags,
    { Name = "private-instances-sg" }
  )
}
