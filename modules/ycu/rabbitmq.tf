variable "RabbitMQ_ami_ids" {
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

variable "RabbitMQ_instance_types" {
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

resource "template_file" "RabbitMQ_user_data" {
  template = "${file("${path.module}/user-data.sh")}"

  vars {
    chef_role = "microservice-rabbitmq"
    domain = "${var.domain}"
    environment = "${var.environment}"
    chef_boot_bucket = "${var.chef_boot_bucket}"
    chef_config_bucket = "${var.chef_config_bucket}"
    consul_bucket = "${var.consul_bucket}"
    elasticsearch_boot_bucket = "${var.elasticsearch_boot_bucket}"
  }
}

resource "aws_security_group" "RabbitMQ-access" {
    name = "${var.environment_name}-RabbitMQ-access"

    ingress {
        from_port = 5671
        to_port = 5672
        protocol = "tcp"
        security_groups = ["${aws_security_group.RabbitMQ_security_group.id}"]
    }
    ingress {
        from_port = 5671
        to_port = 5672
        protocol = "tcp"
        security_groups = ["${aws_security_group.RabbitMQ_elb_security_group.id}"]
    }

    vpc_id = "${aws_vpc.application.id}"
    tags {
        Name        = "${var.environment_name}-RabbitMQ-access"
        Environment = "${var.environment_name}"
    }
}

resource "aws_security_group" "RabbitMQ" {
    name = "${var.environment_name}-RabbitMQ"

    ingress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      self = "true"
    } 
    
    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["${var.venus_cidr_block}"]
    }
    
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["${var.workspaces_cidr_block}"]
    }
    
    ingress {
        from_port   = 15671
        to_port     = 15672
        protocol    = "tcp"
        cidr_blocks = ["${var.workspaces_cidr_block}"]
    }
    ingress {
        from_port   = 5671
        to_port     = 5672
        protocol    = "tcp"
        cidr_blocks = ["${var.workspaces_cidr_block}"]
    }
    
    ingress {
        from_port = 15671
        to_port = 15671
        protocol = "tcp"
        security_groups = ["${aws_security_group.RabbitMQ_elb.id}"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    vpc_id = "${aws_vpc.application.id}"
    tags {
        Name        = "${var.environment_name}-RabbitMQ"
        Environment = "${var.environment_name}"
    }
}

resource "aws_autoscaling_group" "RabbitMQ_group" {
  # XXX: internet_gateway.application??
  depends_on = ["aws_internet_gateway.ycu"]
  #depends_on = ["aws_route.application_admin"]
  vpc_zone_identifier = ["${aws_subnet.application.*.id}"]
  name = "${var.environment}_YCU_RabbitMQ"
  max_size = "${lookup(var.default_asg_max, var.environment)}"
  min_size = "${lookup(var.default_asg_min, var.environment)}"
  health_check_grace_period = "${var.default_asg_health_check_period}"
  health_check_type = "${var.default_asg_health_check_type}"
  desired_capacity = "${lookup(var.default_asg_desired, var.environment)}"
  force_delete = true
  launch_configuration = "${aws_launch_configuration.RabbitMQ_configuration.id}"
  load_balancers = ["${aws_elb.RabbitMQ_elb.name}"]]

  tag {
    key = "Name"
    value = "${var.environment}_YCU_RabbitMQ"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "RabbitMQ_configuration" {
  name                  = "${var.environment}_RabbitMQ"
  image_id              = "${coalesce(lookup(var.RabbitMQ_ami_ids, var.environment), lookup(var.default_ami_ids, var.environment))}"
  instance_type         = "${coalesce(lookup(var.RabbitMQ_instance_types, var.environment), lookup(var.default_instance_types, var.environment))}"
  key_name              = "${var.instance_key_name}"
  security_groups       = ["${aws_security_group.RabbitMQ.id}", "${aws_security_group.RabbitMQ-access.id}"]]
  iam_instance_profile  = "${aws_iam_instance_profile.microservices_profile.name}"
  user_data             = "${template_file.RabbitMQ_user_data.rendered}"
}

