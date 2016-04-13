variable "YCH_CM_ami_ids" {
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

variable "YCH_CM_instance_types" {
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

resource "template_file" "YCH_CM_user_data" {
  template = "${file("${path.module}/user-data.sh")}"

  vars {
    chef_role = "microservice-ych_cm"
    domain = "${var.domain}"
    environment = "${var.environment}"
    chef_boot_bucket = "${var.chef_boot_bucket}"
    chef_config_bucket = "${var.chef_config_bucket}"
    consul_bucket = "${var.consul_bucket}"
    elasticsearch_boot_bucket = "${var.elasticsearch_boot_bucket}"
  }
}

resource "aws_security_group" "YCH_CM" {
    name = "${var.environment}-YCH_CM"
        
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
      cidr_blocks =  ["${var.workspaces_cidr_block}"]

    }

    ingress {
        from_port = 6379
        to_port = 6379
        protocol = "tcp"
        cidr_blocks = ["${var.europa_cidr_block}"]
    }

    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["${var.ariel_cidr_block}"]
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["${var.pluto_cidr_block}]
    }

    ingress {
        from_port = 6033
        to_port = 6033
        protocol = "tcp"
        cidr_blocks =  ["${var.workspaces_cidr_block}"]
    }

    ingress {
        from_port = 8283
        to_port = 8283
        protocol = "tcp"
        security_groups = ["${aws_security_group.ProdPublicCM_elb.id}"]
    }
    ingress {
        from_port = 8283
        to_port = 8283
        protocol = "tcp"
        security_groups = ["${aws_security_group.ProdPublicCMInternal_elb.id}"]
    }
    

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    vpc_id = "${aws_vpc.ycu.id}"
    tags {
        Name        = "${var.environment}-YCH_CM"
        Environment = "${var.environment}"
    }
}

resource "aws_autoscaling_group" "YCH_CM_group" {
  depends_on = ["aws_internet_gateway.ycu"]
  depends_on = ["aws_autoscaling_group.Consul_group"]
  #depends_on = ["aws_route.public_admin"]
  vpc_zone_identifier = ["${aws_subnet.pub.*.id}"]
  name = "${var.environment}_YCH_CM"
  max_size = "${lookup(var.default_asg_max, var.environment)}"
  min_size = "${lookup(var.default_asg_min, var.environment)}"
  health_check_grace_period = "${var.default_asg_health_check_period}"
  health_check_type = "${var.default_asg_health_check_type}"
  desired_capacity = "${lookup(var.default_asg_desired, var.environment)}"
  force_delete = true
  launch_configuration = "${aws_launch_configuration.YCH_CM_configuration.id}"
  load_balancers = ["${aws_elb.ProdPublicCM.name}", "${aws_elb.ProdPublicCMInternal.name}"]

  tag {
    key = "Name"
    value = "${var.environment}_YCH_CM"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "YCH_CM_configuration" {
  name                  = "${var.environment}_YCH_CM"
  image_id              = "${coalesce(lookup(var.YCH_CM_ami_ids, var.environment), lookup(var.default_ami_ids, var.environment))}"
  instance_type         = "${coalesce(lookup(var.YCH_CM_instance_types, var.environment), lookup(var.default_instance_types, var.environment))}"
  key_name              = "${var.instance_key_name}"
  security_groups       = ["${aws_security_group.YCH_CM.id}", "${aws_security_group.consul.id}"]
  iam_instance_profile  = "${aws_iam_instance_profile.microservices_profile.name}"
  user_data             = "${template_file.YCH_CM_user_data.rendered}"
}

