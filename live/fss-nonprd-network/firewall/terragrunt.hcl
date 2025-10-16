locals {
  # Project configuration
  project_name = "fss-nonprd"
  
  availability_zones = [
    "ap-southeast-7a"
  ]
  
  # AWS Configuration
  aws_region = "ap-southeast-7"
  
  # FortiGate Configuration
  fortigate_instance_type = "c7i.large"       # FortiGate instance size (supports up to 4 ENIs)
  fortigate_license_type  = "payg"            # payg (Pay As You Go) or byol (Bring Your Own License)
  fortigate_version      = "7.4.9"           # FortiGate firmware version
  key_pair_name          = "fss-nonprd-fortigate-ssh-instance-key"     # AWS Key Pair for SSH access
  create_key_pair        = true              # Auto-create key pair during deployment
  
  # Leave empty to auto-select latest AMI based on version and license type
  fortigate_ami_id       = "ami-0fa96232e73141f6c"  # Specify custom AMI ID if needed
  
  
  # Single Firewall (No HA)
  # enable_ha = false                         # Single instance firewall
  
  # Management Access
  admin_cidr_blocks = [
    "10.13.0.0/16",                            # Corporate network
    # "49.237.21.103/32"                         # External management network
  ]
  
  # FortiGate Admin Settings
  fortigate_admin_username = "admin"
}

terraform {
  source = "../../../modules/firewall-single"
}

include "root" {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../network-vpc/vpc"
  
  mock_outputs = {
    vpc_id                         = "vpc-mock"
    network_public_subnet_ids     = ["subnet-mock1", "subnet-mock2"]
    network_private_subnet_ids    = ["subnet-mock3", "subnet-mock4"]
    network_mgmt_subnet_ids       = ["subnet-mock7", "subnet-mock8"]
    # heartbeat_subnet_ids not needed for single firewall
  }
}

inputs = {
  # Basic configuration
  project_name       = local.project_name
  availability_zones = local.availability_zones
  aws_region         = local.aws_region
  
  # VPC information from dependency
  vpc_id = dependency.vpc.outputs.vpc_id
  
  # Subnet IDs from VPC module
  public_subnet_ids    = dependency.vpc.outputs.network_public_subnet_ids
  private_subnet_ids   = dependency.vpc.outputs.network_private_subnet_ids
  mgmt_subnet_ids      = dependency.vpc.outputs.network_mgmt_subnet_ids
  # heartbeat_subnet_ids not needed for single firewall
  
  # FortiGate Configuration
  fortigate_instance_type  = local.fortigate_instance_type
  fortigate_license_type   = local.fortigate_license_type
  fortigate_version        = local.fortigate_version
  fortigate_ami_id         = try(local.fortigate_ami_id, "")  # Custom AMI ID (optional)
  key_pair_name            = local.key_pair_name
  create_key_pair          = local.create_key_pair
  
  # Single Firewall Configuration - Custom Private IPs
  mgmt_private_ip    = "10.13.7.254"   # Management interface IP
  public_private_ip  = "10.13.1.254"   # Public interface IP  
  private_private_ip = "10.13.3.254"   # Private interface IP
  
  # Security Configuration
  admin_cidr_blocks        = local.admin_cidr_blocks
  fortigate_admin_username = local.fortigate_admin_username
  
  # Tags
  tags = {
    Project     = local.project_name
    Environment = "NONPRD"
    Created-by  = "TrueIDC"
    Created-at  = formatdate("DD-MMM-YY", timestamp())
    ManagedBy   = "terraform"
    Vendor      = "fortinet"
    Purpose     = "network-security"
  }
}
