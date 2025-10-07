variable "attachment_name" {
  description = "Name for the transit gateway attachment"
  type        = string
}

variable "transit_gateway_id" {
  description = "ID of the Transit Gateway"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID to attach to Transit Gateway"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for Transit Gateway VPC attachment"
  type        = list(string)
}

variable "dns_support" {
  description = "Whether DNS support is enabled for the VPC attachment"
  type        = string
  default     = "enable"
  
  validation {
    condition     = contains(["enable", "disable"], var.dns_support)
    error_message = "dns_support must be either 'enable' or 'disable'."
  }
}

variable "ipv6_support" {
  description = "Whether IPv6 support is enabled for the VPC attachment"
  type        = string
  default     = "disable"
  
  validation {
    condition     = contains(["enable", "disable"], var.ipv6_support)
    error_message = "ipv6_support must be either 'enable' or 'disable'."
  }
}

variable "appliance_mode_support" {
  description = "Whether Appliance Mode support is enabled for the VPC attachment"
  type        = string
  default     = "disable"
  
  validation {
    condition     = contains(["enable", "disable"], var.appliance_mode_support)
    error_message = "appliance_mode_support must be either 'enable' or 'disable'."
  }
}

variable "route_table_association_id" {
  description = "Transit Gateway Route Table ID to associate with this attachment (optional)"
  type        = string
  default     = ""
}

variable "route_table_propagation_id" {
  description = "Transit Gateway Route Table ID to propagate routes to (optional)"
  type        = string
  default     = ""
}

variable "custom_routes" {
  description = "Map of custom routes to create for this attachment"
  type = map(object({
    destination_cidr_block = string
    route_table_id        = string
    blackhole             = optional(bool, false)
  }))
  default = {}
}

variable "prefix_list_references" {
  description = "Map of prefix list references to create for this attachment"
  type = map(object({
    prefix_list_id = string
    route_table_id = string
    blackhole      = optional(bool, false)
  }))
  default = {}
}

variable "tags" {
  description = "Common tags to be assigned to all resources"
  type        = map(any)
  default     = {}
}