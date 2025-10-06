variable "aws_configuration" {
  type = map(string)
  default = {
    region = ""
    profile = ""
  }
}

variable "tags" {
  type = map(any)
  default = {}
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "vpc_name" {
  type = string
  default = "poc-ntb-network-vpc"
}

variable "vpc_dns_support" {
  type    = bool
  default = true
}

variable "vpc_dns_hostnames" {
  type    = bool
  default = true
}

variable "project_name" {
  description = "Name for resources"
  type        = string
  default     = "project-default"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "network_public_subnet_cidrs" {
  description = "CIDR blocks for network public subnets"
  type        = list(string)
}

variable "network_private_subnet_cidrs" {
  description = "CIDR blocks for network private subnets"
  type        = list(string)
}

variable "network_tgw_subnet_cidrs" {
  description = "CIDR blocks for private subnets used for Transit Gateway attachment"
  type        = list(string)
}

variable "network_mgmt_subnet_cidrs" {
  description = "CIDR blocks for network management subnets"
  type        = list(string)
}

variable "network_heartbeat_subnet_cidrs" {
  description = "CIDR blocks for network heartbeat subnets"
  type        = list(string)
}
