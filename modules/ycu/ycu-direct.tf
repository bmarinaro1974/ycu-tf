variable "YCU-Direct_ami_ids" {
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

variable "YCU-Direct_instance_types" {
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



resource "aws_security_group" "YCU-Direct_elb" {
  name = "${var.environment}-YCU-Direct-elb"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks =  ["${var.workspaces_cidr_block}"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = "${aws_vpc.ycu.id}"
  tags {
    Name        = "${var.environment}-YCU-Direct-elb"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group" "YCU-Direct-Internal_elb_security_group" {
  name = "${var.environment}-YCU-Direct-Internal-elb"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks =  ["${var.workspaces_cidr_block}"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = "${aws_vpc.ycu.id}"
  tags {
    Name        = "${var.environment}-YCU-Direct-Internal-elb"
    Environment = "${var.environment}"
  }
}

resource "aws_elb" "YCU-Direct_elb" {
  name = "${var.environment}-YCU-Direct"
  subnets = ["${aws_subnet.pub.*.id}"]
  security_groups = ["${aws_security_group.YCU-Direct_elb_security_group.id}"]

  listener {
    instance_port = 8583
    instance_protocol = "https"
    lb_port = 443
    lb_protocol = "https"
    ssl_certificate_id = "${var.elb_certs.developmentCertificate}"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 5
    target = "HTTPS:8583/direct-service/cm/person/ping"
    interval = 30
  }

  cross_zone_load_balancing = true
  idle_timeout = 60
  connection_draining = true
  connection_draining_timeout = 300

  tags {
    Name = "${var.environment}-YCU-Direct"
  }
}

resource "aws_elb" "YCU-Direct-Internal_elb" {
  name = "${var.environment}-YCU-Direct-Internal"
  subnets = ["${aws_subnet.pub.*.id}"]
  security_groups = ["${aws_security_group.YCU-Direct-Internal_elb_security_group.id}"]

  listener {
    instance_port = 8583
    instance_protocol = "https"
    lb_port = 443
    lb_protocol = "https"
    ssl_certificate_id = "${var.elb_certs.developmentCertificate}"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 5
    target = "HTTPS:8583/direct-service/cm/person/ping"
    interval = 30
  }

  cross_zone_load_balancing = true
  idle_timeout = 60
  connection_draining = true
  connection_draining_timeout = 300

  tags {
    Name = "${var.environment}-YCU-Direct-Internal"
  }
}
resource "aws_route53_record" "YCU-Direct-elb" {
  zone_id = "${var.existing_route53_zones.yourcareuniverse_net_id}"
  name = "${var.dns_elb_YCU-Direct.record}"
  type = "${var.dns_elb_YCU-Direct.type}"

  alias {
    name = "${aws_elb.YCU-Direct.dns_name}"
    zone_id = "${aws_elb.YCU-Direct.zone_id}"
    evaluate_target_health = false
  }
}

variable "dns_elb_YCU-Direct" {
  default = {
    record = "dev-6-0-YCU-Direct-elb.app"
    type = "A"
  }
}


resource "aws_elb" "YCU-Direct" {
  name = "${var.environment}-YCU-Direct"
  subnets = ["${aws_subnet.pub.*.id}"]
  security_groups = ["${aws_security_group.YCU-Direct_elb_security_group.id}"]

  listener {
    instance_port = 8583
    instance_protocol = "https"
    lb_port = 443
    lb_protocol = "https"
    ssl_certificate_id = "${var.elb_certs.developmentCertificate}"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 5
    target = "HTTPS:8583/direct-service/cm/person/ping"
    interval = 30
  }

  cross_zone_load_balancing = true
  idle_timeout = 60
  connection_draining = true
  connection_draining_timeout = 300

  tags {
    Name = "${var.environment}-YCU-Direct"
  }
}

resource "aws_elb" "YCU-Direct-Internal" {
  name = "${var.environment}-YCU-Direct-Internal"
  subnets = ["${aws_subnet.pub.*.id}"]
  security_groups = ["${aws_security_group.YCU-Direct-Internal_elb_security_group.id}"]

  listener {
    instance_port = 8583
    instance_protocol = "https"
    lb_port = 443
    lb_protocol = "https"
    ssl_certificate_id = "${var.elb_certs.developmentCertificate}"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 5
    target = "HTTPS:8583/direct-service/cm/person/ping"
    interval = 30
  }

  cross_zone_load_balancing = true
  idle_timeout = 60
  connection_draining = true
  connection_draining_timeout = 300

  tags {
    Name = "${var.environment}-YCU-Direct-Internal"
  }
}


resource "aws_security_group" "YCU-Direct" {
    name = "${var.environment}-YCU-Direct"
        
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
        from_port = 8583
        to_port = 8583
        protocol = "tcp"
        security_groups = ["${aws_security_group.YCU-Direct_elb.id}"]
    }
    
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["${var.pluto_cidr_block}"]
    }
    
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    vpc_id = "${aws_vpc.ycu.id}"
    tags {
        Name        = "${var.environment}-YCU-Direct"
        Environment = "${var.environment}"
    }
}


resource "template_file" "YCU-Direct_user_data" {
  template = "${file("${path.module}/user-data.sh")}"

  vars {
    chef_role = "microservice-ycu-direct"
    domain = "${var.domain}"
    environment = "${var.environment}"
    chef_boot_bucket = "${var.chef_boot_bucket}"
    chef_config_bucket = "${var.chef_config_bucket}"
    consul_bucket = "${var.consul_bucket}"
    elasticsearch_boot_bucket = "${var.elasticsearch_boot_bucket}"
  }
}

resource "aws_autoscaling_group" "YCU-Direct_group" {
  depends_on = ["aws_internet_gateway.ycu"]
  depends_on = ["aws_autoscaling_group.Consul_group"]
  #depends_on = ["aws_route.public_admin"]
  vpc_zone_identifier = ["${aws_subnet.pub.*.id}"]
  name = "${var.environment}_YCU-Direct"
  max_size = "${lookup(var.default_asg_max, var.environment)}"
  min_size = "${lookup(var.default_asg_min, var.environment)}"
  health_check_grace_period = "${var.default_asg_health_check_period}"
  health_check_type = "${var.default_asg_health_check_type}"
  desired_capacity = "${lookup(var.default_asg_desired, var.environment)}"
  force_delete = true
  launch_configuration = "${aws_launch_configuration.YCU-Direct_configuration.id}"
  load_balancers = ["${aws_elb.YCU-Direct.name}", "${aws_elb.YCU-Direct-Internal.name}"]

  tag {
    key = "Name"
    value = "${var.environment}_YCU-Direct"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "YCU-Direct_configuration" {
  name                  = "${var.environment}_YCU-Direct"
  image_id              = "${coalesce(lookup(var.YCU-Direct_ami_ids, var.environment), lookup(var.default_ami_ids, var.environment))}"
  instance_type         = "${coalesce(lookup(var.YCU-Direct_instance_types, var.environment), lookup(var.default_instance_types, var.environment))}"
  key_name              = "${var.instance_key_name}"
  security_groups       = "${aws_security_group.YCU-Direct_security_group.id}", "${aws_security_group.consul.id}"]
  iam_instance_profile  = "${aws_iam_instance_profile.microservices_profile.name}"
  user_data             = "${template_file.YCU-Direct_user_data.rendered}"
}

