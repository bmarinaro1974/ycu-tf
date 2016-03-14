variable "default_min_asg_size" {
  description = ""
  type        = "map"
  default     = {
    prod  = "ami-60b6c60a"
    stage = "ami-60b6c60a"
    demo  = "ami-60b6c60a"
    qa    = "ami-60b6c60a"
    dev   = "ami-60b6c60a"
  }
}

variable "default_max_asg_size" {
  description = ""
  type        = "map"
  default     = {
    prod  = "ami-60b6c60a"
    stage = "ami-60b6c60a"
    demo  = "ami-60b6c60a"
    qa    = "ami-60b6c60a"
    dev   = "ami-60b6c60a"
  }
}