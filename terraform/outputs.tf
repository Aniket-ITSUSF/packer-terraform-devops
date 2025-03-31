output "amazon_linux_private_ips" {
  description = "IPs of Amazon Linux EC2 instances"
  value       = [for instance in aws_instance.amazon_linux_instances : instance.private_ip]
}

output "ubuntu_private_ips" {
  description = "IPs of Ubuntu EC2 instances"
  value       = [for instance in aws_instance.ubuntu_instances : instance.private_ip]
}

output "ansible_controller_private_ip" {
  description = "IP of Ansible Controller"
  value       = aws_instance.ansible_controller.private_ip
}

output "bastion_public_ip" {
  description = "Public IP of Bastion Host"
  value       = aws_instance.bastion.public_ip
}
