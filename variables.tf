variable "aws_profile" {
  description = "The AWS profile to run the TF in"
  type = string
}

variable "region" {
  description = "The AWS region to deploy into."
  type        = string
  default = "us-west-2"
}

variable "vpc_cidr_block" {
  description = "CIDR block for VPC."
  type        = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets."
  type        = list(string)
  # default = ["10.0.1.0/28", "10.0.1.16/28", "10.0.1.32/28"]
  default = ["10.0.1.0/28"]
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets."
  type        = list(string)
  # default = ["10.0.100.0/24", "10.0.101.0/24", "10.0.102.0/24"]
  default = ["10.0.100.0/24"]
}

variable "name_prefix" {
  description = "A prefix to use in resource names, e.g., example-vpc"
  type        = string
  default = "test-vpc"
}