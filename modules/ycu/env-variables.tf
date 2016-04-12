variable "environment" {
  description   = ""
  type          = "string"
}

variable "version" {
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
    Consul="microservice-consul"
    ConsulHAProxy="microservice-consul-haproxy"
    ETL="microservice-etl"
    Elasticsearch="microservice-elasticsearch"
    Marvel="microservice-marvel"
    RabbitMQ="microservice-rabbitmq"
    Reporting="microservice-reporting"
    Spago="microservice-spago"
    YCH-OpenEMPY="microservice-ych-openempi"
    YCH_CM="microservice-ych_cm"
    YCH_Portal_Worker="microservice-ych_portal_worker"
    YCR="microservice-ycr"
    YCU-Direct="microservice-ycu-direct"
    EMPI-Services="microservice-empi-services"
    Event-Sync="microservice-event-sync"
    Facility-50="microservice-facility-50"
    Legacy-EMPI-Service="microservice-legacy-empi-service"
    Location="microservice-location"
    permission-management="microservice-permission-management"
    PixPDQ="microservice-pixpdq"
    Profile="microservice-profile"
    Scheduling="microservice-scheduling"
    Security="microservice-security"
    Swagger-UI="microservice-swagger-ui"
    Wellness-Services="microservice-wellness-services"
    ycd-Dictionary="microservice-ycd-dictionary"
    YCI-50="microservice-yci-50"
    Notification="microservice-notification"
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

##############################################
# Mystery cidr blocks (named after planets in vague order of appearence)
###########################################
variable "mercury_cidr_block" {
  type = "string"
  default = "10.13.10.0/25"
}

variable "venus_cidr_block" {
  type = "string"
  default = "10.17.10.0/24"
}

variable "venus_prime_cidr_block" {
  type = "string"
  default = "10.17.10.0/16"
}

variable "earth_cidr_block" {
  type = "string"
  default = "10.27.10.0/24"
}

variable "moon_cidr_block" {
  type = "string"
  default = "10.27.20.0/24"
}

variable "mars_cidr_block" {
  type = "string"
  default = "10.32.10.0/24"
}

variable "jupiter_cidr_block" {
  type = "string"
  default = "10.12.10.0/25"
}

variable "europa_cidr_block" {
  type = "string"
  default = "10.12.10.128/26"
}

variable "saturn_cidr_block" {
  type = "string"
  default = "10.37.11.0/26"
}

variable "neptune_cidr_block" {
  type = "string"
  default = "10.37.11.192/26"
}

variable "triton_cidr_block" {
  type = "string"
  default = "10.37.10.64/26"
}

variable "uranus_cidr_block" {
  type = "string"
  default = "10.17.11.0/26"
}

variable "miranda_cidr_block" {
  type = "string"
  default = "10.17.12.128/26"
}

variable "umbriel_cidr_block" {
  type = "string"
  default = "10.17.10.64/26"
}

variable "ariel_cidr_block" {
  type = "string"
  default = "10.17.10.128/26"
}

variable "titania_cidr_block" {
  type = "string"
  default = "10.17.10.192/26"
}

variable "pluto_cidr_block" {
  type = "string"
  default = "10.50.0.0/16"
}

variable "kepler18f_cidr_block" {
  type = "string"
  default = "10.31.11.0/24"
}

variable "kepler16b_cidr_block" {
  type "string"
  default = "172.31.0.0/16"
}



