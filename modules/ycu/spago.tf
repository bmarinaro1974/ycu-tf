variable "Spago_ami_ids" {
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

variable "Spago_instance_types" {
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

resource "aws_security_group" "Spago_elb" {
  name = "${var.environment}-Spago-elb"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = "${aws_vpc.ycu.id}"
  tags {
    Name        = "${var.environment}-Spago-elb"
    Environment = "${var.environment}"
  }
}

resource "aws_elb" "Spago" {
  name = "${var.environment}-Spago"
  #XXX: public subnet?! HOW MANY SUBNETS ARE THERE? (like, 4 right?)
  subnets = ["${aws_subnet.pub.*.id}"]
  security_groups = ["${aws_security_group.Spago_elb.id}"]

  listener {
    instance_port = 8983
    instance_protocol = "https"
    lb_port = 443
    lb_protocol = "https"
    ssl_certificate_id = "${var.elb_certs.developmentCertificate}"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 5
    target = "HTTPS:8983/yca/index.html"
    interval = 30
  }

  cross_zone_load_balancing = true
  idle_timeout = 60
  connection_draining = true
  connection_draining_timeout = 300

  tags {
    Name = "${var.environment}-Spago"
  }
}



variable "dns_elb_Spago" {
  default = {
    record = "dev-6-0-Spago-elb.app"
    type = "A"
  }
}

resource "aws_route53_record" "Spago-elb" {
  zone_id = "${var.existing_route53_zones.yourcareuniverse_net_id}"
  name = "${var.dns_elb_Spago.record}"
  type = "${var.dns_elb_Spago.type}"

  alias {
    name = "${aws_elb.Spago.dns_name}"
    zone_id = "${aws_elb.Spago.zone_id}"
    evaluate_target_health = false
  }
}


resource "template_file" "Spago_user_data" {
  template = "${file("${path.module}/user-data.sh")}"

  vars {
    chef_role = "microservice-spago"
    domain = "${var.domain}"
    environment = "${var.environment}"
    chef_boot_bucket = "${var.chef_boot_bucket}"
    chef_config_bucket = "${var.chef_config_bucket}"
    consul_bucket = "${var.consul_bucket}"
    elasticsearch_boot_bucket = "${var.elasticsearch_boot_bucket}"
  }
}

resource "aws_security_group" "Spago_security_group" {
    name = "${var.environment}-Spago"
        
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
        from_port = 8983
        to_port = 8983
        protocol = "tcp"
        security_groups = ["${aws_security_group.Spago_elb.id}"]
    }
    
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        security_groups = ["${aws_security_group.Spago_elb.id}"]
    }
    
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    # XXX: public VPC? :(
    vpc_id = "${aws_vpc.ycu.id}"
    tags {
        Name        = "${var.environment}-Spago"
        Environment = "${var.environment}"
    }
}

resource "aws_autoscaling_group" "Spago_group" {
  # XXX: gateway.public ??
  depends_on = ["aws_internet_gateway.ycu"]
  #depends_on = ["aws_route.public_admin"]
  vpc_zone_identifier = ["${aws_subnet.pub.*.id}"]
  name = "${var.environment}_YCU_Spago"
  max_size = "${lookup(var.default_asg_max, var.environment)}"
  min_size = "${lookup(var.default_asg_min, var.environment)}"
  health_check_grace_period = "${var.default_asg_health_check_period}"
  health_check_type = "${var.default_asg_health_check_type}"
  desired_capacity = "${lookup(var.default_asg_desired, var.environment)}"
  force_delete = true
  launch_configuration = "${aws_launch_configuration.Spago_configuration.id}"
  load_balancers = ["${aws_elb.Spago.name}"
 
  tag {
    key = "Name"
    value = "${var.environment}_YCU_Spago"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "Spago_configuration" {
  name                  = "${var.environment}_Spago"
  image_id              = "${coalesce(lookup(var.Spago_ami_ids, var.environment), lookup(var.default_ami_ids, var.environment))}"
  instance_type         = "${coalesce(lookup(var.Spago_instance_types, var.environment), lookup(var.default_instance_types, var.environment))}"
  key_name              = "${var.instance_key_name}"
  security_groups       = ["${aws_security_group.spago.id}", ["${aws_security_group.consul-enabled.id}"]
  iam_instance_profile  = "${aws_iam_instance_profile.microservices_profile.name}"
  user_data             = "${template_file.Spago_user_data.rendered}"
}

