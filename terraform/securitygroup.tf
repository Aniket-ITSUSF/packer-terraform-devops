data "http" "my_ip" {
  url = "https://api.ipify.org?format=text" // fetch your ip address
}

resource "aws_security_group" "bastion-allow-ssh" {
  vpc_id      = module.vpc.vpc_id
  name        = "bastion-allow-ssh"
  description = "Security group for bastion"

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
    var.resource_tags, { Name = "bastion-allow-ssh" }
  )
}

resource "aws_security_group" "private-ssh" {
  vpc_id      = module.vpc.vpc_id
  name        = "private-ssh"
  description = "Security group for private subnet instances"

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
    security_groups = [ aws_security_group.bastion-allow-ssh.id ]
  }

  tags = merge(
    var.resource_tags,
    { Name = "private-ssh" }
  )
}
