locals {
  # Project configuration
  project_name = "fss-prd"
  
  availability_zones = [
    "ap-southeast-7a",
    "ap-southeast-7b"
  ]
  
  # Transit Gateway Configuration
  amazon_side_asn = 64512  # Private ASN for AWS side
  
  # Transit Gateway Settings
  auto_accept_shared_attachments  = "disable"  # Disable auto-accept of spoke account attachments
  default_route_table_association = "disable"  # Disable auto-association with default route table
  default_route_table_propagation = "disable"  # Disable auto-propagation to default route table
  dns_support                     = "enable"   # Enable DNS resolution
  vpn_ecmp_support               = "enable"   # Enable VPN ECMP
  enable_multicast_support       = false      # Disable multicast (not needed for most use cases)
}

terraform {
  source = "../../modules/transit-gateway"
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

inputs = {
  # Basic configuration
  project_name       = local.project_name
  availability_zones = local.availability_zones
  
  # VPC information from dependency
  vpc_id         = dependency.vpc.outputs.vpc_id
  tgw_subnet_ids = dependency.vpc.outputs.network_tgw_subnet_ids
  
  # Transit Gateway Configuration
  amazon_side_asn                 = local.amazon_side_asn
  auto_accept_shared_attachments  = local.auto_accept_shared_attachments
  default_route_table_association = local.default_route_table_association
  default_route_table_propagation = local.default_route_table_propagation
  dns_support                     = local.dns_support
  vpn_ecmp_support               = local.vpn_ecmp_support
  enable_multicast_support       = local.enable_multicast_support
  
  # Tags
  tags = {
    Project     = local.project_name
    Environment = "PRD"
    Created-by  = "TrueIDC"
    Created-at  = formatdate("DD-MMM-YY", timestamp())
    ManagedBy   = "terraform"
    Purpose     = "network-connectivity"
  }
}
