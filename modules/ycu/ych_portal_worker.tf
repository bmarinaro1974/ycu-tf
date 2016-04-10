variable "YCH_Portal_Worker_ami_ids" {
  description = ""
  type        = "map"
  default     = {
    dev1=""
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

# Defines instance type for the hl7 autoscaling group.
### NOTE: CHANGE IN environment-variables.tf AS AMIS ARE DEFINED ###

variable "YCH_Portal_Worker_instance_types" {
  description = ""
  type        = "map"
  default     = {
    dev1=""
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


resource "aws_security_group" "YCH_Portal_Worker" {
    name = "${var.environment_name}-YCH_Portal_Worker"
        
    ingress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      self = "true"
    } 

    ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["192.168.2.0/24"]
    }

    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["10.17.10.128/26"]
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["10.50.0.0/16"]
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        security_groups = ["${aws_security_group.Prod_Public_Portal.id}"]
    }

    ingress {
        from_port = 8187
        to_port = 8187
        protocol = "tcp"
        security_groups = ["${aws_security_group.Prod_Public_Portal.id}"]
    }

    ingress {
        from_port = 8183
        to_port = 8183
        protocol = "tcp"
        security_groups = ["${aws_security_group.Prod_Public_Portal.id}"]
    }
    
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    vpc_id = "${aws_vpc.public.id}"
    tags {
        Name        = "${var.environment_name}-YCH_Portal_Worker"
        Environment = "${var.environment_name}"
    }
}

resource "template_file" "YCH_Portal_Worker_user_data" {
  template = "${file("${path.module}/user-data.sh")}"

  vars {
    chef_role = "microservice-ych_portal_worker"
    domain = "${var.domain}"
    environment = "${var.environment}"
    chef_boot_bucket = "${var.chef_boot_bucket}"
    chef_config_bucket = "${var.chef_config_bucket}"
    consul_bucket = "${var.consul_bucket}"
    elasticsearch_boot_bucket = "${var.elasticsearch_boot_bucket}"
  }
}

resource "aws_autoscaling_group" "YCH_Portal_Worker_group" {
  depends_on = ["aws_internet_gateway.ycu"]
  depends_on = ["aws_autoscaling_group.Consul_group"]
  #depends_on = ["aws_route.public_admin"]
  vpc_zone_identifier = ["${aws_subnet.public.*.id}"]
  name = "${var.environment}_YCH_Portal_Worker"
  max_size = "${lookup(var.default_asg_max, var.environment)}"
  min_size = "${lookup(var.default_asg_min, var.environment)}"
  health_check_grace_period = "${var.default_asg_health_check_period}"
  health_check_type = "${var.default_asg_health_check_type}"
  desired_capacity = "${lookup(var.default_asg_desired, var.environment)}"
  force_delete = true
  launch_configuration = "${aws_launch_configuration.YCH_Portal_Worker_configuration.id}"

  tag {
    key = "Name"
    value = "${var.environment}_YCH_Portal_Worker"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "YCH_Portal_Worker_configuration" {
  name                  = "${var.environment}_YCH_Portal_Worker"
  image_id              = "${coalesce(lookup(var.YCH_Portal_Worker_ami_ids, var.environment), lookup(var.default_ami_ids, var.environment))}"
  instance_type         = "${coalesce(lookup(var.YCH_Portal_Worker_instance_types, var.environment), lookup(var.default_instance_types, var.environment))}"
  key_name              = "${var.instance_key_name}"
  security_groups       = ["${aws_security_group.YCH_Portal_Worker.id}", "${aws_security_group.consul-enabled-public.id}"]
  iam_instance_profile  = "${aws_iam_instance_profile.microservices_profile.name}"
  user_data             = "${template_file.YCH_Portal_Worker_user_data.rendered}"
}

