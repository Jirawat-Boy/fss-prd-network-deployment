output "fortigate_primary_instance_id" {
  description = "Instance ID of the primary FortiGate"
  value       = aws_instance.fortigate_primary.id
}

output "fortigate_secondary_instance_id" {
  description = "Instance ID of the secondary FortiGate"
  value       = var.enable_ha ? aws_instance.fortigate_secondary[0].id : null
}

output "fortigate_primary_mgmt_eip" {
  description = "Management Elastic IP of the primary FortiGate"
  value       = aws_eip.fortigate_primary_mgmt_eip.public_ip
}

output "fortigate_secondary_mgmt_eip" {
  description = "Management Elastic IP of the secondary FortiGate"
  value       = var.enable_ha ? aws_eip.fortigate_secondary_mgmt_eip[0].public_ip : null
}

output "fortigate_primary_public_eip" {
  description = "Public Elastic IP of the primary FortiGate"
  value       = aws_eip.fortigate_primary_public_eip.public_ip
}
  
# Elastic IP for Secondary Public Interface Only (HA)
# output "fortigate_secondary_public_eip" {
#   description = "Public Elastic IP of the secondary FortiGate"
#   value       = var.enable_ha ? aws_eip.fortigate_secondary_public_eip[0].public_ip : null
# }

output "fortigate_primary_mgmt_private_ip" {
  description = "Management private IP of the primary FortiGate"
  value       = aws_network_interface.fortigate_primary_mgmt.private_ip
}

output "fortigate_primary_public_private_ip" {
  description = "Public interface private IP of the primary FortiGate"
  value       = aws_network_interface.fortigate_primary_public.private_ip
}

output "fortigate_primary_private_private_ip" {
  description = "Private interface private IP of the primary FortiGate"
  value       = aws_network_interface.fortigate_primary_private.private_ip
}

output "fortigate_security_groups" {
  description = "Security groups created for FortiGate"
  value = {
    management = aws_security_group.fortigate_mgmt_sg.id
    public     = aws_security_group.fortigate_public_sg.id
    private    = aws_security_group.fortigate_private_sg.id
    heartbeat  = aws_security_group.fortigate_heartbeat_sg.id
  }
}

output "fortigate_network_interfaces" {
  description = "Network interfaces created for FortiGate"
  value = {
    primary = {
      management = aws_network_interface.fortigate_primary_mgmt.id
      public     = aws_network_interface.fortigate_primary_public.id
      private    = aws_network_interface.fortigate_primary_private.id
      heartbeat  = var.enable_ha ? aws_network_interface.fortigate_primary_heartbeat[0].id : null
    }
    secondary = var.enable_ha ? {
      management = aws_network_interface.fortigate_secondary_mgmt[0].id
      public     = aws_network_interface.fortigate_secondary_public[0].id
      private    = aws_network_interface.fortigate_secondary_private[0].id
      heartbeat  = aws_network_interface.fortigate_secondary_heartbeat[0].id
    } : null
  }
}

output "fortigate_secondary_mgmt_private_ip" {
  description = "Management private IP of the secondary FortiGate"
  value       = var.enable_ha ? aws_network_interface.fortigate_secondary_mgmt[0].private_ip : null
}

output "fortigate_admin_urls" {
  description = "Admin URLs for FortiGate management"
  value = {
    primary   = "https://${aws_eip.fortigate_primary_mgmt_eip.public_ip}"
    secondary = var.enable_ha ? "https://${aws_eip.fortigate_secondary_mgmt_eip[0].public_ip}" : null
  }
}

# Key Pair Information
output "key_pair_name" {
  description = "Name of the key pair used for FortiGate instances"
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
