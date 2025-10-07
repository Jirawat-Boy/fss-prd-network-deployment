output "attachment_id" {
  description = "ID of the VPC attachment"
  value       = aws_ec2_transit_gateway_vpc_attachment.main.id
}

output "vpc_owner_id" {
  description = "Identifier of the AWS account that owns the VPC"
  value       = aws_ec2_transit_gateway_vpc_attachment.main.vpc_owner_id
}

output "subnet_ids" {
  description = "Subnet IDs used for the attachment"
  value       = aws_ec2_transit_gateway_vpc_attachment.main.subnet_ids
}

output "route_table_association_id" {
  description = "ID of the route table association (if created)"
  value       = var.route_table_association_id != "" ? aws_ec2_transit_gateway_route_table_association.main[0].id : null
}

output "route_table_propagation_id" {
  description = "ID of the route table propagation (if created)"
  value       = var.route_table_propagation_id != "" ? aws_ec2_transit_gateway_route_table_propagation.main[0].id : null
}

output "custom_routes" {
  description = "Map of custom routes created"
  value = {
    for k, v in aws_ec2_transit_gateway_route.custom_routes : k => {
      destination_cidr_block = v.destination_cidr_block
      route_table_id        = v.transit_gateway_route_table_id
      blackhole             = v.blackhole
    }
  }
}

output "prefix_list_references" {
  description = "Map of prefix list references created"
  value = {
    for k, v in aws_ec2_transit_gateway_prefix_list_reference.main : k => {
      prefix_list_id = v.prefix_list_id
      route_table_id = v.transit_gateway_route_table_id
      blackhole      = v.blackhole
    }
  }
}