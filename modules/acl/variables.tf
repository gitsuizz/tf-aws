variable "vpc_id" {
  description = "VPC ID for the NACL"
  type        = string
}

variable "network_acl_rules" {
  type = list(object({
    cidr_block = string
    protocol = number # Use numeric values (e.g., 6 for TCP)
    rule_action = string # "allow" or "deny"
    rule_number = number
    egress = bool   # Whether the rule is an egress rule or not.
  }))
}

# variable "nacl_id"  {
#   description = "NACL ID"
#   type        = string
# }
