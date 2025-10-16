output "fortigate_instance_id" {
  description = "Instance ID of the FortiGate"
  value       = aws_instance.fortigate.id
}

output "fortigate_mgmt_eip" {
  description = "Management Elastic IP of the FortiGate"
  value       = aws_eip.fortigate_mgmt_eip.public_ip
}

output "fortigate_public_eip" {
  description = "Public Elastic IP of the FortiGate"
  value       = aws_eip.fortigate_public_eip.public_ip
}

output "fortigate_mgmt_private_ip" {
  description = "Management private IP of the FortiGate"
  value       = aws_network_interface.fortigate_mgmt.private_ip
}

output "fortigate_public_private_ip" {
  description = "Public interface private IP of the FortiGate"
  value       = aws_network_interface.fortigate_public.private_ip
}

output "fortigate_private_private_ip" {
  description = "Private interface private IP of the FortiGate"
  value       = aws_network_interface.fortigate_private.private_ip
}

output "fortigate_security_groups" {
  description = "Security groups created for FortiGate"
  value = {
    management = aws_security_group.fortigate_mgmt_sg.id
    public     = aws_security_group.fortigate_public_sg.id
    private    = aws_security_group.fortigate_private_sg.id
  }
}

output "fortigate_network_interfaces" {
  description = "Network interfaces created for FortiGate"
  value = {
    management = aws_network_interface.fortigate_mgmt.id
    public     = aws_network_interface.fortigate_public.id
    private    = aws_network_interface.fortigate_private.id
  }
}

output "fortigate_admin_url" {
  description = "Admin URL for FortiGate management"
  value       = "https://${aws_eip.fortigate_mgmt_eip.public_ip}"
}

# Key Pair Information
output "key_pair_name" {
  description = "Name of the key pair used for FortiGate instance"
  value       = var.create_key_pair ? aws_key_pair.fortigate_key_pair[0].key_name : var.key_pair_name
}

output "key_pair_fingerprint" {
  description = "Fingerprint of the key pair"
  value       = var.create_key_pair ? aws_key_pair.fortigate_key_pair[0].fingerprint : null
}

output "private_key_file_path" {
  description = "Path to the generated private key file (if created)"
  value       = var.create_key_pair && var.public_key_content == "" ? "${path.root}/${var.key_pair_name}.pem" : null
}

output "private_key_content" {
  description = "Private key content (sensitive)"
  value       = var.create_key_pair && var.public_key_content == "" ? tls_private_key.fortigate_key[0].private_key_pem : null
  sensitive   = true
}

# AMI Information
output "fortigate_ami_id" {
  description = "AMI ID used for FortiGate instance"
  value       = local.fortigate_ami_id
}

output "fortigate_ami_name" {
  description = "Name of the AMI used for FortiGate instance"
  value       = var.fortigate_ami_id != "" ? "Custom AMI: ${var.fortigate_ami_id}" : data.aws_ami.fortigate[0].name
}