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

resource "aws_security_group" "RabbitMQ_elb" {
  name = "${var.environment}-RabbitMQ_elb"

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    self = "true"
  }

  ingress {
    from_port   = 15671
    to_port     = 15672
    protocol    = "tcp"
    cidr_blocks = ["${var.workspaces_cidr_block}"]

  }
  ingress {
    from_port   = 5671
    to_port     = 5671
    protocol    = "tcp"
    cidr_blocks = ["${var.workspaces_cidr_block}"]

  }

  ingress {
    from_port   = 5671
    to_port     = 5672
    protocol    = "tcp"
    cidr_blocks = ["${var.venus_prime_cidr_block}"]

  }

  ingress {
    from_port   = 5671
    to_port     = 5672
    protocol    = "tcp"
    cidr_blocks = ["${var.earth_cidr_block}"]

  }

  ingress {
    from_port   = 5671
    to_port     = 5672
    protocol    = "tcp"
    cidr_blocks = ["${var.saturn_cidr_block}"]

  }

  ingress {
    from_port   = 5671
    to_port     = 5672
    protocol    = "tcp"
    cidr_blocks = ["${var.neptune_cidr_block}"]

  }

  ingress {
    from_port = 5671
    to_port = 5671
    protocol = "tcp"
    security_groups = ["${aws_security_group.Elasticsearch.id}"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = "${aws_vpc.ycu.id}"
  tags {
    Name        = "${var.environment}-RabbitMQ_elb"
    Environment = "${var.environment}"
  }
}

resource "aws_elb" "RabbitMQ" {
  name = "${var.environment}-RabbitMQ"
  subnets = ["${aws_subnet.application.*.id}"]
  security_groups = ["${aws_security_group.RabbitMQ_elb.id}", "${aws_security_group.RabbitMQ-access.id}"]

  listener {
    instance_port = 5671
    instance_protocol = "tcp"
    lb_port = 5671
    lb_protocol = "tcp"
  }

  listener {
    instance_port = 15671
    instance_protocol = "tcp"
    lb_port = 15671
    lb_protocol = "tcp"
  }

  health_check {
    healthy_threshold = 10
    unhealthy_threshold = 2
    timeout = 5
    target = "TCP:5671"
    interval = 30
  }

  cross_zone_load_balancing = true
  idle_timeout = 60
  connection_draining = true
  connection_draining_timeout = 300

  tags {
    Name = "${var.environment}-RabbitMQ"
  }
}
variable "dns_elb_RabbitMQ" {
  default = {
    record = "dev-6-0-RabbitMQ-elb.app"
    type = "A"
  }
}

resource "aws_route53_record" "RabbitMQ-elb" {
  zone_id = "${var.existing_route53_zones.yourcareuniverse_net_id}"
  name = "${var.dns_elb_RabbitMQ.record}"
  type = "${var.dns_elb_RabbitMQ.type}"

  alias {
    name = "${aws_elb.RabbitMQ.dns_name}"
    zone_id = "${aws_elb.RabbitMQ.zone_id}"
    evaluate_target_health = false
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
    name = "${var.environment}-RabbitMQ-access"

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

    vpc_id = "${aws_vpc.ycu.id}"
    tags {
        Name        = "${var.environment}-RabbitMQ-access"
        Environment = "${var.environment}"
    }
}

resource "aws_security_group" "RabbitMQ" {
    name = "${var.environment}-RabbitMQ"

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

    vpc_id = "${aws_vpc.ycu.id}"
    tags {
        Name        = "${var.environment}-RabbitMQ"
        Environment = "${var.environment}"
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
  load_balancers = ["${aws_elb.RabbitMQ.name}"]]

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

