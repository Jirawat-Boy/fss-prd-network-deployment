locals {
  # Project configuration
  project_name = "fss-prd"
  
  # Attachment Configuration
  attachment_name = "fss-prd-network-tgw"  # Name for this specific attachment
  
  # VPC Attachment Settings
  dns_support             = "enable"   # Enable DNS resolution through TGW
  ipv6_support           = "disable"  # Disable IPv6 support
  appliance_mode_support = "enable"  # Enable appliance mode
  
  # Route Table Configuration (optional)
  # Leave empty strings to skip association/propagation
  route_table_association_id = ""  # Will be set via dependency or manually
  route_table_propagation_id = ""  # Will be set via dependency or manually
  
  # Custom Routes (optional)
  custom_routes = {
    # Example: Route specific traffic to this VPC
    # "default_route" = {
    #   destination_cidr_block = "0.0.0.0/0"
    #   route_table_id        = "tgw-rtb-xxxxx"
    #   blackhole             = false
    # }
  }
  
  # Prefix List References (optional)
  prefix_list_references = {
    # Example: Reference AWS service prefix lists
    # "s3_prefix_list" = {
    #   prefix_list_id = "pl-xxxxx"
    #   route_table_id = "tgw-rtb-xxxxx"
    #   blackhole      = false
    # }
  }
}

terraform {
  source = "../../modules/transit-gateway-attachment"
}

include "root" {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../network-vpc/vpc"
  
  mock_outputs = {
    vpc_id                    = "vpc-mock"
    network_tgw_subnet_ids   = ["subnet-mock1", "subnet-mock2"]
  }
}

dependency "tgw" {
  config_path = "../network-tgw"
  
  mock_outputs = {
    transit_gateway_id           = "tgw-mock"
    custom_route_table_id       = "tgw-rtb-mock-ips"
    custom_route_table_spoke_id = "tgw-rtb-mock-spoke"
  }
}

inputs = {
  # Basic configuration
  attachment_name    = local.attachment_name
  transit_gateway_id = dependency.tgw.outputs.transit_gateway_id
  
  # VPC information from dependency
  vpc_id     = dependency.vpc.outputs.vpc_id
  subnet_ids = dependency.vpc.outputs.network_tgw_subnet_ids
  
  # Attachment Configuration
  dns_support             = local.dns_support
  ipv6_support           = local.ipv6_support
  appliance_mode_support = local.appliance_mode_support
  
  # Route Table Configuration (use TGW IPS route table for inspection)
  route_table_association_id = dependency.tgw.outputs.custom_route_table_id
  route_table_propagation_id = ""  # No propagation - manual route control only
  
  # Custom routing (optional)
  custom_routes          = local.custom_routes
  prefix_list_references = local.prefix_list_references
  
  # Tags
  tags = {
    Project     = local.project_name
    Environment = "PRD"
    Created-by  = "TrueIDC"
    Created-at  = formatdate("DD-MMM-YY", timestamp())
    ManagedBy   = "terraform"
    Purpose     = "network-connectivity"
    Type        = "VPCAttachment"
  }
}