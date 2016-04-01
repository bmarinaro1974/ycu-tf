variable "environment" {
  description   = ""
  type          = "string"
}

variable "region" {
  description   = ""
  type          = "string"
  default       = "us-east-1"
}

variable "zones" {
  type = "map"
  default = {
    us-east-1 = "us-east-1b,us-east-1d,us-east-1e"
    us-west-1 = "us-west-1a,us-west-1b,us-west-1c"
    us-west-2 = "us-west-2a,us-west-2b,us-west-2c"
  }
}

variable "provider_primary_account" {
  description = ""
  type = "string"
}

variable "instance_key_name" {
  type = "string"
}


variable "elb_logging_account" {
  description = ""
  type        = "map"
  default     = {
    us-east-1 = "127311923021"
    us-west-1 = "027434742980"
    us-west-2 = "797873946194"
  }
}

variable "default_ami_ids" {
  type = "map"
  default = {
    dev1 = "ami-8fcee4e5"
    dev2 = "ami-8fcee4e5"
    dev3 = "ami-8fcee4e5"
    dev4 = "ami-8fcee4e5"
    qa1  = "ami-8fcee4e5"
    qa2  = "ami-8fcee4e5"
    qa3  = "ami-8fcee4e5"
    qa4  = "ami-8fcee4e5"
    demo = "ami-8fcee4e5"
    stage = "ami-8fcee4e5"
    prod = "ami-8fcee4e5"
  }
}

variable "default_asg_min" {
  type = "map"
  default = {
    dev1="1"
    dev2="1"
    dev3="1"
    dev4="1"
    qa1="1"
    qa2="1"
    qa3="1"
    qa4="1"
    stage="1"
    prod="1"
  }
}


variable "default_asg_max" {
  type = "map"
  default = {
    dev1="1"
    dev2="1"
    dev3="1"
    dev4="1"
    qa1="1"
    qa2="1"
    qa3="1"
    qa4="1"
    stage="1"
    prod="1"
  }
}

variable "default_asg_desired" {
  type = "map"
  default = {
    dev1="1"
    dev2="1"
    dev3="1"
    dev4="1"
    qa1="1"
    qa2="1"
    qa3="1"
    qa4="1"
    stage="1"
    prod="1"
  }
}

variable "default_asg_health_check_period" {
  type = "string"
  default = "300"
}

variable "default_asg_health_check_type" {
  type = "string"
  default = "EC2"
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


#fix this up later

variable "default_instance_types" {
  type = "map"
  default = {
    dev1="t2.small"
    dev2="t2.small"
    dev3="t2.small"
    dev4="t2.small"
    qa1="t2.small"
    qa2="t2.small"
    qa3="t2.small"
    qa4="t2.small"
    stage="m3.medium"
    prod="m3.medium"
  }
}

variable "instance_tenancy" {
  type = "map"
  default = {
    dev1="default"
    dev2="default"
    dev3="default"
    dev4="default"
    qa1="default"
    qa2="default"
    qa3="default"
    qa4="default"
    stage="dedicated"
    prod="dedicated"
  }
}


variable "domain" {
  type = "map"
  default = {
    dev1="app.yourcareuniverse.net"
    dev2=""
    dev3=""
    dev4=""
    qa1=""
    qa2=""
    qa3=""
    qa4=""
    stage=""
    prod=""
  }
}

variable "roles" {
  type = "map"
  default = {
    YCE-Services="microservice-yce-services"
    Swagger-UI="microservice-swagger-ui"

  }
}

variable "admin_cidr_block" {
  type = "string"
  default = "10.50.1.0/24"
}

variable "workspaces_cidr_block" {
  type = "string"
  default = "192.168.2.0/24"
}


