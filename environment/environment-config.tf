variable "environment" {
  type = "string"
}

variable "region" {
  type = "string"
  default = "us-east-1"
}

variable "instance_key_name" {
  type = "string"
  default = "terraform-ycu-baa"
}

variable "chef_boot_bucket" {
  type = "string"
  default = "ycu-chef-boot"
}

variable "chef_config_bucket" {
  type = "string"
  default = "ycu-chef-config"
}

variable "consul_bucket" {
  type = "string"
  default = "ycu-consul"
}

variable "elasticsearch_boot_bucket" {
  type = "string"
  default = "ycu-elasticsearch-boot"
}

variable "workspace" {
  type = "string"
}


provider "aws" {
  allowed_account_ids = ["${var.provider_primary.account}"]
  access_key = "${var.provider_primary.access_key}"
  secret_key = "${var.provider_primary.secret_key}"
  region     = "${var.region}"
}

# Sets up an environment that is analogous to the production environment

module "application" {
  source = "../modules/ycu"
  environment = "${var.environment}"
  region = "${var.region}"
  provider_primary_account = "${var.provider_primary.account}"
  instance_key_name = "${var.instance_key_name}"
  chef_boot_bucket = "${var.chef_boot_bucket}"
  chef_config_bucket = "${var.chef_config_bucket}"
  consul_bucket = "${var.consul_bucket}"
  elasticsearch_boot_bucket = "${var.elasticsearch_boot_bucket}"
}
