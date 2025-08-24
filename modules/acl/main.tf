data "aws_vpc" "selected_vpc" {
  id = var.vpc_id
}

data "aws_subnets" "public_subnets" {
  filter {
    name = "vpc-id"
    values = [var.vpc_id]
  }

  tags = {
    SubnetType = "PublicSubnet"
  }
}

locals {
  validated_rules = [
    for rule in var.network_acl_rules : rule if rule.rule_number > 100
  ]

  invalid_rule_numbers = [for r in var.network_acl_rules : r.rule_number if r.rule_number <= 100]
}

resource "aws_network_acl" "default_acl" {
  vpc_id = var.vpc_id

  tags = {
    Name        = "${data.aws_vpc.selected_vpc.tags["Name"]}-default-acl"
    Environment = "dev"
  }
}

resource "aws_network_acl_rule" "custom_acl_list" {
  count         = length(local.validated_rules)

  network_acl_id       = aws_network_acl.default_acl.id
  egress = local.validated_rules[count.index].egress ? true : false
  protocol = local.validated_rules[count.index].protocol
  rule_action = local.validated_rules[count.index].rule_action == "allow" ? "allow" : "deny"
  rule_number = local.validated_rules[count.index].rule_number
  cidr_block      = local.validated_rules[count.index].cidr_block
}

# Network ACL Inbound Rules (Add as per requirement)
resource "aws_network_acl_rule" "example_nacl_inbound" {
  network_acl_id = aws_network_acl.default_acl.id
  rule_number = 1
  protocol = "-1"
  rule_action = "allow"
  egress = false
  from_port = 0
  to_port = 65535
  cidr_block = "0.0.0.0/0"
}

# Network ACL Outbound Rules (Add as per requirement)
resource "aws_network_acl_rule" "example_nacl_outbound" {
  network_acl_id = aws_network_acl.default_acl.id
  rule_number = 2
  protocol = "-1"
  rule_action = "allow"
  egress = true
  from_port = 0
  to_port = 65535
  cidr_block = "0.0.0.0/0"
}

resource "aws_network_acl_association" "subnet_assocations" {
  for_each = toset(data.aws_subnets.public_subnets.ids)
  network_acl_id      = aws_network_acl.default_acl.id
  subnet_id           = each.value
}


# # If there are any invalid rule numbers, raise an error.
# resource "null_resource" "validate_rule_numbers" {
#   count = length(local.invalid_rule_numbers) > 0 ? length(local.invalid_rule_numbers) : 0
#
#   triggers = {
#     for idx, num in local.invalid_rule_numbers : format("invalid-rule-number-%d", idx) => num
#   }
#
#   provisioner "local-exec" {
#     command = <<EOF
# echo "The following rule numbers must be greater than 100: ${join(", ", var.triggers)}"
# EOF
#
#     environment = {
#       triggers = jsonencode(values(var.null_resource.validate_rule_numbers.triggers))
#     }
#   }
# }