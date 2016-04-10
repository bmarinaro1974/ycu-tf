resource "aws_security_group" "Consul-HAProxy_security_group" {
    name = "${var.environment_name}-Consul-HAProxy"
        
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
      cidr_blocks = ["${var.workspaces_cidr_block}"]
    }

    ingress {
        from_port = 7001
        to_port = 7001
        protocol = "tcp"
        cidr_blocks = ["${var.moon_cidr_block}"]
    }
    ingress {
        from_port = 7001
        to_port = 7001
        protocol = "tcp"
        cidr_blocks = ["${var.triton_cidr_block}"]
    }
    ingress {
        from_port = 7001
        to_port = 7001
        protocol = "tcp"
        cidr_blocks = ["${var.uranus_cidr_block}"]
    }
    ingress {
        from_port = 7001
        to_port = 7001
        protocol = "tcp"
        cidr_blocks = ["${var.miranda_cidr_block}"]
    }
    ingress {
        from_port = 7001
        to_port = 7001
        protocol = "tcp"
        cidr_blocks = ["${var.umbriel_cidr_block}"]
    }
    ingress {
        from_port = 7001
        to_port = 7001
        protocol = "tcp"
        cidr_blocks = ["${var.ariel_cidr_block}"]
    }
    ingress {
        from_port = 7001
        to_port = 7001
        protocol = "tcp"
        cidr_blocks = ["${var.titania_cidr_block}"]
    }
    ingress {
        from_port = 7001
        to_port = 7001
        protocol = "tcp"
        security_groups = ["${aws_security_group.Prod_Public_Portal_security_group.id}"]
    }
    ingress {
        from_port = 7001
        to_port = 7001
        protocol = "tcp"
        security_groups = ["${aws_security_group.Consul-HAProxy_elb.id}"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    #XXX: VPC_id change needed
    vpc_id = "${aws_vpc.public.id}"
    tags {
        Name        = "${var.environment_name}-Consul-HAProxy"
        Environment = "${var.environment_name}"
    }
}

variable "Consul-HAProxy_ami_ids" {
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

variable "Consul-HAProxy_instance_types" {
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

resource "template_file" "Consul-HAProxy_user_data" {
  template = "${file("${path.module}/user-data.sh")}"

  vars {
    chef_role = "microservice-consul-haproxy"
    domain = "${var.domain}"
    environment = "${var.environment}"
    chef_boot_bucket = "${var.chef_boot_bucket}"
    chef_config_bucket = "${var.chef_config_bucket}"
    consul_bucket = "${var.consul_bucket}"
    elasticsearch_boot_bucket = "${var.elasticsearch_boot_bucket}"
  }
}

resource "aws_autoscaling_group" "Consul-HAProxy_group" {
  #XXX: gateway?
  depends_on = ["aws_internet_gateway.ycu"]
  depends_on = ["aws_autoscaling_group.Consul_group"]
  #depends_on = ["aws_route.public_admin"]
  vpc_zone_identifier = ["${aws_subnet.public.*.id}"]
  name = "${var.environment}_YCU_Consul-HAProxy"
  max_size = "${lookup(var.default_asg_max, var.environment)}"
  min_size = "${lookup(var.default_asg_min, var.environment)}"
  health_check_grace_period = "${var.default_asg_health_check_period}"
  health_check_type = "${var.default_asg_health_check_type}"
  desired_capacity = "${lookup(var.default_asg_desired, var.environment)}"
  force_delete = true
  launch_configuration = "${aws_launch_configuration.Consul-HAProxy_configuration.id}"
  load_balancers = ["${aws_elb.Consul-HAProxy_elb.name}"]
  
  tag {
    key = "Name"
    value = "${var.environment}_YCU_Consul-HAProxy"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "Consul-HAProxy_configuration" {
  name                  = "${var.environment}_Consul-HAProxy"
  image_id              = "${coalesce(lookup(var.Consul-HAProxy_ami_ids, var.environment), lookup(var.default_ami_ids, var.environment))}"
  instance_type         = "${coalesce(lookup(var.Consul-HAProxy_instance_types, var.environment), lookup(var.default_instance_types, var.environment))}"
  key_name              = "${var.instance_key_name}"
  security_groups       = ["${aws_security_group.Consul-HAProxy.id}", "${aws_security_group.consul-enabled-public_security_group.id}"]
  iam_instance_profile  = "${aws_iam_instance_profile.microservices_profile.name}"
  user_data             = "${template_file.Consul-HAProxy_user_data.rendered}"
}
