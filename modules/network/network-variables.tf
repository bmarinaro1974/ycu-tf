# tf files have words separated by dashes and tf resources and ariables use underscores
# input variables required to know what we're creating

variable "environment" {
  description = "dev, qa, staging, demo, prod"
  type = "string"
}

variable "region" {
  description = "us-east-1, us-west-1, us-west-2"
  type = "string"
}

#internal variables for use within this module

variable "ycu_cidr_block" {
  description = ""
  type = "string"
  default = "10.0.0.0/8"
}

variable "region_cidr_newnums" {
  type = "map"
  default = {
    us-east-1 = 0
    us-west-1 = 1
    us-west-2 = 2
    reserved = 3
  }
}

module "region_cidr_block" {
  source = "../pass-thru/"
  value = "${cidrsubnet(var.ycu_cidr_block,2 ,lookup(var.region_cidr_newnums,var.region ) )}"
}

variable "env_cidr_newnums" {
  type = "string"
  default = "dev1,dev2,dev3,dev4,qa1,qa2,qa3,qa4,stage,prod"
  # because I have a /16 once I'm done with env_cidr_block below,
  # i can set up to 64 values in each region the default value list above
}

module "env_cidr_block" {
  source = "../pass-thru/"
  value = "${cidrsubnet(module.region_cidr_block.value,6 ,index(split(",",var.env_cidr_newnums ),var.environment ) )}"
}

# -----------------------------------------------outputs-----------------------------------------

output "region_cidr_block" {
  value = "${module.region_cidr_block.value}"
}

output "env_cidr_block" {
  value = "${module.env_cidr_block.value}"
}

