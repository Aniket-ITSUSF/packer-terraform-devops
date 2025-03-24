data "aws_ami" "ec2_image" {
  most_recent = true
  owners      = ["self"]
  filter {
    name = "name"
    values = ["amazon-linux-docker*"]
  }
}

resource "aws_instance" "ec2" {
  count         = 6
  ami           = data.aws_ami.ec2_image.id
  instance_type = "t2.micro"
  subnet_id = module.vpc.private_subnets[0]
  vpc_security_group_ids = [aws_security_group.private-ssh.id]

  tags = merge(
    var.resource_tags,
    { Name = "ami-private-ec2-${format("%02d", count.index + 1)}" }
  )
}
