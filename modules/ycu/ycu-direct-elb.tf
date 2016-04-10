

resource "aws_security_group" "YCU-Direct_elb" {
    name = "${var.environment_name}-YCU-Direct-elb"

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

    vpc_id = "${aws_vpc.public.id}"
    tags {
        Name        = "${var.environment_name}-YCU-Direct-elb"
        Environment = "${var.environment_name}"
    }
}

resource "aws_security_group" "YCU-Direct-Internal_elb_security_group" {
    name = "${var.environment_name}-YCU-Direct-Internal-elb"

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

    vpc_id = "${aws_vpc.public.id}"
    tags {
        Name        = "${var.environment_name}-YCU-Direct-Internal-elb"
        Environment = "${var.environment_name}"
    }
}

resource "aws_elb" "YCU-Direct_elb" {
  name = "${var.environment_name}-YCU-Direct"
  subnets = ["${aws_subnet.public-subnet-A-nat.id}", "${aws_subnet.public-subnet-C-nat.id}", "${aws_subnet.public-subnet-D-nat.id}", "${aws_subnet.public-subnet-E-nat.id}", ]
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
    Name = "${var.environment_name}-YCU-Direct"
  }
}

resource "aws_elb" "YCU-Direct-Internal_elb" {
  name = "${var.environment_name}-YCU-Direct-Internal"
  subnets = ["${aws_subnet.public-subnet-A-nat.id}", "${aws_subnet.public-subnet-C-nat.id}", "${aws_subnet.public-subnet-D-nat.id}", "${aws_subnet.public-subnet-E-nat.id}", ]
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
    Name = "${var.environment_name}-YCU-Direct-Internal"
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
  name = "${var.environment_name}-YCU-Direct"
  subnets = ["${aws_subnet.public-subnet-A-nat.id}", "${aws_subnet.public-subnet-C-nat.id}", "${aws_subnet.public-subnet-D-nat.id}", "${aws_subnet.public-subnet-E-nat.id}", ]
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
    Name = "${var.environment_name}-YCU-Direct"
  }
}

resource "aws_elb" "YCU-Direct-Internal" {
  name = "${var.environment_name}-YCU-Direct-Internal"
  subnets = ["${aws_subnet.public-subnet-A-nat.id}", "${aws_subnet.public-subnet-C-nat.id}", "${aws_subnet.public-subnet-D-nat.id}", "${aws_subnet.public-subnet-E-nat.id}", ]
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
    Name = "${var.environment_name}-YCU-Direct-Internal"
  }
}
