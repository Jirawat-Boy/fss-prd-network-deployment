locals {
  # Project configuration
  project_name = "fss-nonprd"
  
  availability_zones = [
    "ap-southeast-7a",  # Primary AZ
    "ap-southeast-7b"   # Secondary AZ
  ]
}

terraform {
  source = "../../../../modules/vpc"
}

include "root" {
  path = find_in_parent_folders()
}

inputs = {
  # VPC Configuration
  project_name = local.project_name
  vpc_cidr     = "10.13.0.0/16"
  
  # Availability Zones
  availability_zones = local.availability_zones

  # Network Public Subnets
  network_public_subnet_cidrs = [
    "10.13.1.0/24",  # ap-southeast-7a
    "10.13.2.0/24"   # ap-southeast-7b
  ]

  # Network Private Subnets
  network_private_subnet_cidrs = [
    "10.13.3.0/24",  # ap-southeast-7a
    "10.13.4.0/24"   # ap-southeast-7b
  ]

  # Network TGW Subnets
  network_tgw_subnet_cidrs = [
    "10.13.225.0/24",  # ap-southeast-7a
    "10.13.226.0/24"   # ap-southeast-7b
  ]

  # Network Heartbeat Subnets
  network_heartbeat_subnet_cidrs = [
    "10.13.5.0/24",  # ap-southeast-7a
    "10.13.6.0/24"   # ap-southeast-7b
  ]

  # Network Management Subnets
  network_mgmt_subnet_cidrs = [
    "10.13.7.0/24",   # ap-southeast-7a
    "10.13.8.0/24"   # ap-southeast-7b
  ]
  
  # Tags
  tags = {
    Project     = local.project_name
    Environment = "NONPRD"
    Created-by  = "TrueIDC"
    Created-at  = formatdate("DD-MMM-YY", timestamp())
    ManagedBy   = "terraform"
  }
}
