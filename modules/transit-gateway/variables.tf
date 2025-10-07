variable "project_name" {
  description = "Name for resources"
  type        = string
  default     = "project-default"
}

# VPC-specific variables moved to transit-gateway-attachment module

variable "amazon_side_asn" {
  description = "The Autonomous System Number (ASN) for the Amazon side of the gateway"
  type        = number
  default     = 64512
}

variable "auto_accept_shared_attachments" {
  description = "Whether resource attachment requests are automatically accepted"
  type        = string
  default     = "enable"
  
  validation {
    condition     = contains(["enable", "disable"], var.auto_accept_shared_attachments)
    error_message = "auto_accept_shared_attachments must be either 'enable' or 'disable'."
  }
}

variable "default_route_table_association" {
  description = "Whether resource attachments are automatically associated with the default association route table"
  type        = string
  default     = "enable"
  
  validation {
    condition     = contains(["enable", "disable"], var.default_route_table_association)
    error_message = "default_route_table_association must be either 'enable' or 'disable'."
  }
}

variable "default_route_table_propagation" {
  description = "Whether resource attachments automatically propagate routes to the default propagation route table"
  type        = string
  default     = "enable"
  
  validation {
    condition     = contains(["enable", "disable"], var.default_route_table_propagation)
    error_message = "default_route_table_propagation must be either 'enable' or 'disable'."
  }
}

variable "dns_support" {
  description = "Whether DNS support is enabled"
  type        = string
  default     = "enable"
  
  validation {
    condition     = contains(["enable", "disable"], var.dns_support)
    error_message = "dns_support must be either 'enable' or 'disable'."
  }
}

variable "vpn_ecmp_support" {
  description = "Whether VPN Equal Cost Multipath Protocol support is enabled"
  type        = string
  default     = "enable"
  
  validation {
    condition     = contains(["enable", "disable"], var.vpn_ecmp_support)
    error_message = "vpn_ecmp_support must be either 'enable' or 'disable'."
  }
}

variable "enable_multicast_support" {
  description = "Whether multicast support is enabled"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Common tags to be assigned to all resources"
  type        = map(any)
  default     = {}
}
