module "network" {
  source = "../network/"
  environment = "${var.env}"
  region = "${var.region}"
}

module "pub_cidr_block" {
  source = "../pass-thru/"
  value = "${cidrsubnet(module.network.env_cidr_block,3,0)}"
}

module "web_cidr_block" {
  source = "../pass-thru/"
  value = "${cidrsubnet(module.network.env_cidr_block,3,1)}"
}

module "svc_cidr_block" {
  source = "../pass-thru/"
  value = "${cidrsubnet(module.network.env_cidr_block,3,2)}"
}

module "app_cidr_block" {
  source = "../pass-thru/"
  value = "${cidrsubnet(module.network.env_cidr_block,3,3)}"
}

module "data_cidr_block" {
  source = "../pass-thru/"
  value = "${cidrsubnet(module.network.env_cidr_block,3,4)}"
}

module "res0_cidr_block" {
  source = "../pass-thru/"
  value = "${cidrsubnet(module.network.env_cidr_block,3,5)}"
}

module "res1_cidr_block" {
  source = "../pass-thru/"
  value = "${cidrsubnet(module.network.env_cidr_block,3,6)}"
}

module "res2_cidr_block" {
  source = "../pass-thru/"
  value = "${cidrsubnet(module.network.env_cidr_block,3,7)}"
}

