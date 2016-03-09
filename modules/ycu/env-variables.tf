variable "env" {
  type = "string"
}

variable "region" {
  type = "string"
}

variable "zones" {
  type = "map"
  default = {
    us-east-1 = "us-east-1a,us-east-1b,us-east-1c"
    us-west-1 = "us-west-1a,us-west-1b,us-west-1c"
    us-west-2 = "us-west-2a,us-west-2b,us-west-2c"
  }
}

variable "default_ami_ids" {
  type = "map"
  default = {
    dev1 = ""
    dev2 = ""
    dev3 = ""
    dev4 = ""
    qa1  = ""
    qa2  = ""
    qa3  = ""
    qa4  = ""
    demo = ""
    stage = ""
    prod = ""
  }
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

