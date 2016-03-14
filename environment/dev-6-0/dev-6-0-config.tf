vvariable "environment" {
  type = "string"
  default = "dev1"
}

variable "region" {
  type = "string"
  default = "us-east-1"
}

variable "instance_key_name" {
  type = "string"
  default = "terraform-ycu"
}

provider "aws" {
  allowed_account_ids = ["${var.provider_primary.account}"]
  access_key = "${var.provider_primary.access_key}"
  secret_key = "${var.provider_primary.secret_key}"
  region     = "${var.region}"
}

# Sets up an environment that is analogous to the production environment

module "application" {
  source = "../../modules/ycu"
  environment = "${var.environment}"
  region = "${var.region}"
  provider_primary_account = "${var.provider_primary.account}"
  instance_key_name = "${var.instance_key_name}"
}