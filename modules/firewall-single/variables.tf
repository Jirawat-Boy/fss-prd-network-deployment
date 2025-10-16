variable "project_name" {
  description = "Name for resources"
  type        = string
  default     = "project-default"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID where FortiGate will be deployed"
  type        = string
}

variable "mgmt_subnet_ids" {
  description = "Management subnet IDs for FortiGate management interface"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for FortiGate public interface"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for FortiGate private interface"
  type        = list(string)
}

variable "mgmt_private_ip" {
  description = "Private IP address for management interface"
  type        = string
  default     = "10.22.7.254"
}

variable "public_private_ip" {
  description = "Private IP address for public interface"
  type        = string
  default     = "10.22.1.254"
}

variable "private_private_ip" {
  description = "Private IP address for private interface"
  type        = string
  default     = "10.22.3.254"
}

variable "fortigate_instance_type" {
  description = "EC2 instance type for FortiGate"
  type        = string
  default     = "c5.large"
}

variable "fortigate_license_type" {
  description = "FortiGate license type (byol or payg)"
  type        = string
  default     = "payg"
  validation {
    condition     = contains(["byol", "payg"], var.fortigate_license_type)
    error_message = "License type must be either 'byol' or 'payg'."
  }
}

variable "fortigate_version" {
  description = "FortiGate firmware version"
  type        = string
  default     = "7.4.5"
}

variable "key_pair_name" {
  description = "AWS Key Pair name for FortiGate instance"
  type        = string
}

variable "create_key_pair" {
  description = "Whether to create a new key pair or use existing one"
  type        = bool
  default     = true
}

variable "public_key_content" {
  description = "Public key content for creating key pair (optional, will generate if not provided)"
  type        = string
  default     = ""
}

variable "admin_cidr_blocks" {
  description = "CIDR blocks allowed for FortiGate management access"
  type        = list(string)
  default     = ["10.0.0.0/8"]
}

variable "fortigate_admin_username" {
  description = "Admin username for FortiGate"
  type        = string
  default     = "admin"
}

variable "tags" {
  description = "Common tags to be assigned to all resources"
  type        = map(any)
  default     = {}
}

variable "aws_region" {
  description = "AWS region for FortiGate deployment"
  type        = string
  default     = "ap-southeast-7"
}

variable "fortigate_ami_id" {
  description = "Custom FortiGate AMI ID. If not specified, will use data source to find latest AMI based on version and license type"
  type        = string
  default     = ""
}