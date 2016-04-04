variable "environment" {
  type = "string"
}

variable "region" {
  type = "string"
}

variable "instance_key_name" {
  type = "string"
}

variable "chef_boot_bucket" {
  type = "string"
}

variable "chef_config_bucket" {
  type = "string"
}

variable "consul_bucket" {
  type = "string"
}

variable "elasticsearch_boot_bucket" {
  type = "string"
}

variable "provider_primary_account" {
  type = "string"
}

variable "provider_primary_access_key" {
  type = "string"
}

variable "provider_primary_secret_key" {
  type = "string"
}

provider "aws" {
  allowed_account_ids = ["${var.provider_primary_account}"]
  access_key = "${var.provider_primary_access_key}"
  secret_key = "${var.provider_primary_secret_key}"
  region     = "${var.region}"
}

# Sets up an environment that is analogous to the production environment

module "application" {
  source = "../../modules/ycu"
  environment = "${var.environment}"
  region = "${var.region}"
  provider_primary_account = "${var.provider_primary.account}"
  instance_key_name = "${var.instance_key_name}"
  chef_boot_bucket = "${var.chef_boot_bucket}"
  chef_config_bucket = "${var.chef_config_bucket}"
  consul_bucket = "${var.consul_bucket}"
  elasticsearch_boot_bucket = "${var.elasticsearch_boot_bucket}"
}