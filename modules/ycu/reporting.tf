variable "Reporting_ami_ids" {
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

variable "Reporting_instance_types" {
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

resource "aws_security_group" "Reporting_security_group" {
    name = "${var.environment_name}-Reporting"
        
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
        from_port = 8983
        to_port = 8983
        protocol = "tcp"
        security_groups = ["${aws_security_group.Reporting_elb_security_group.id}"]
    }
    
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        security_groups = ["${aws_security_group.Reporting_elb_security_group.id}"]
    }
    
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    vpc_id = "${aws_vpc.application.id}"
    tags {
        Name        = "${var.environment_name}-Reporting"
        Environment = "${var.environment_name}"
    }
}

resource "template_file" "Reporting_user_data" {
  template = "${file("${path.module}/user-data.sh")}"

  vars {
    chef_role = "microservice-reporting"
    domain = "${var.domain}"
    environment = "${var.environment}"
    chef_boot_bucket = "${var.chef_boot_bucket}"
    chef_config_bucket = "${var.chef_config_bucket}"
    consul_bucket = "${var.consul_bucket}"
    elasticsearch_boot_bucket = "${var.elasticsearch_boot_bucket}"
  }
}

resource "aws_autoscaling_group" "Reporting_group" {
  depends_on = ["aws_internet_gateway.ycu"]
  #depends_on = ["aws_route.application_admin"]
  vpc_zone_identifier = ["${aws_subnet.application.*.id}"]
  name = "${var.environment}_YCU_Reporting"
  max_size = "${lookup(var.default_asg_max, var.environment)}"
  min_size = "${lookup(var.default_asg_min, var.environment)}"
  health_check_grace_period = "${var.default_asg_health_check_period}"
  health_check_type = "${var.default_asg_health_check_type}"
  desired_capacity = "${lookup(var.default_asg_desired, var.environment)}"
  force_delete = true
  launch_configuration = "${aws_launch_configuration.Reporting_configuration.id}"
  load_balancers = ["${aws_elb.Reporting.name}"]

  tag {
    key = "Name"
    value = "${var.environment}_YCU_Reporting"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "Reporting_configuration" {
  name                  = "${var.environment}_Reporting"
  image_id              = "${coalesce(lookup(var.Reporting_ami_ids, var.environment), lookup(var.default_ami_ids, var.environment))}"
  instance_type         = "${coalesce(lookup(var.Reporting_instance_types, var.environment), lookup(var.default_instance_types, var.environment))}"
  key_name              = "${var.instance_key_name}"
  security_groups       = ["${aws_security_group.Reporting.id}", "${aws_security_group.consul-enabled-application_security_group.id}"]
  iam_instance_profile  = "${aws_iam_instance_profile.microservices_profile.name}"
  user_data             = "${template_file.Reporting_user_data.rendered}"
}
