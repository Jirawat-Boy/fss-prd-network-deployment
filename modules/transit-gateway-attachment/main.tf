# VPC Attachment to Transit Gateway
resource "aws_ec2_transit_gateway_vpc_attachment" "main" {
  subnet_ids         = var.subnet_ids
  transit_gateway_id = var.transit_gateway_id
  vpc_id             = var.vpc_id
  
  # Attachment Configuration
  dns_support                     = var.dns_support
  ipv6_support                   = var.ipv6_support
  appliance_mode_support         = var.appliance_mode_support
  
  tags = merge(var.tags, {
    Name = "${var.attachment_name}-attachment"
    Type = "VPCAttachment"
  })
}

# Route Table Association (optional)
resource "aws_ec2_transit_gateway_route_table_association" "main" {
  count = var.route_table_association_id != "" ? 1 : 0
  
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.main.id
  transit_gateway_route_table_id = var.route_table_association_id
}

# Route Table Propagation (optional)
resource "aws_ec2_transit_gateway_route_table_propagation" "main" {
  count = var.route_table_propagation_id != "" ? 1 : 0
  
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.main.id
  transit_gateway_route_table_id = var.route_table_propagation_id
}

# Custom Routes (optional)
resource "aws_ec2_transit_gateway_route" "custom_routes" {
  for_each = var.custom_routes
  
  destination_cidr_block         = each.value.destination_cidr_block
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.main.id
  transit_gateway_route_table_id = each.value.route_table_id
  blackhole                     = try(each.value.blackhole, false)
}

# Prefix List Reference Routes (optional)
resource "aws_ec2_transit_gateway_prefix_list_reference" "main" {
  for_each = var.prefix_list_references
  
  prefix_list_id                 = each.value.prefix_list_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.main.id
  transit_gateway_route_table_id = each.value.route_table_id
  blackhole                     = try(each.value.blackhole, false)
}