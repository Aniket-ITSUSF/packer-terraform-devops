output "bastion_public_dns" {
  description = "DNS of EC2 (PUBLIC / BASTION)"
  value       = aws_instance.bastion.public_dns
}

output "ec2_private_dns" {
  description = "DNS of EC2 (PRIVATE)"
  value = [for dns in aws_instance.ec2 : dns.private_dns]
}
