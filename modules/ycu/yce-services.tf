variable "YCE-Services_ami_ids" {
  description = ""
  type        = "map"
  default     = {
    prod  = ""
    stage = ""
    demo  = ""
    qa    = ""
    dev   = ""
  }
}

# Defines instance type for the hl7 autoscaling group.
### NOTE: CHANGE IN environment-variables.tf AS AMIS ARE DEFINED ###

variable "YCE-Services_instance_types" {
  description = ""
  type        = "map"
  default     = {
    prod  = ""
    stage = ""
    demo  = ""
    qa    = ""
    dev   = ""
  }
}


# Defines a security group for the hl7 ASG.

resource "aws_security_group" "YCE-Services" {
  name = "${var.environment}-YCE-Services-security-group"
  vpc_id = "${aws_vpc.ycu.id}"

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    security_groups = ["${aws_security_group.hl7_elb.id}"]
  }

  ingress {
    from_port = 2575
    to_port = 2575
    protocol = "tcp"
    security_groups = ["${aws_security_group.hl7_elb.id}"]
  }

  tags {
    Name        = "${var.environment}-hl7-security-group"
    Environment = "${var.environment}"
  }


  resource "template_file" "YCE-Services_user_data" {
    template                = "${file("${path.module}/user-data.sh")}"

    vars {
      domain       = "${lookup(var.domain, var.environment)}"
      chef_role         = "${lookup(var.chef_roles, "YCE-Services")}"
      environment  = "${var.environment}"
    }
  }
}


resource "aws_launch_configuration" "YCE-Services_configuration" {
  name                  = "${var.environment_name}_YCE-Services"
  image_id              = "${coalesce(lookup(var.YCE-Services_ami_ids, var.environment), lookup(var.default_ami_ids, var.environment))}"
  instance_type         = "${coalesce(lookup(var.YCE-Services_instance_types, var.environment), lookup(var.default_instance_types, var.environment))}"
  key_name              = "${var.instance_key_name}"
  security_groups       = ["${aws_security_group.microservices_security_group.id}", "${aws_security_group.consul-enabled-services_security_group.id}"]
  iam_instance_profile  = "${element(aws_iam_instance_profile.application.*.name, lookup(var.profile_indexes, "YCE-Services"))}"
  user_data             = "${template_file.YCE-Services_user_data.rendered}"
}


resource "aws_autoscaling_group" "YCE-Services_group" {
  depends_on = ["aws_internet_gateway.ycu"]
  depends_on = ["aws_autoscaling_group.Consul_group"]
  #depends_on = ["aws_route.services_admin"]
  vpc_zone_identifier = ["${aws_subnet.services.*.id}"]
  name = "${var.environment_name}_YCE_Services"
  max_size = "${var.default_asg_max}"
  min_size = "${var.default_asg_min}"
  health_check_grace_period = "${var.default_asg_health_check_period}"
  health_check_type = "${var.default_asg_health_check_type}"
  desired_capacity = "${var.default_asg_desired}"
  force_delete = true
  launch_configuration = "${aws_launch_configuration.YCE-Services_configuration.id}"

  tag {
    key = "Name"
    value = "${var.environment_name}_YCE_Services"
    propagate_at_launch = true
  }
}