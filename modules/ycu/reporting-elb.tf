variable "dns_elb_Reporting" {
    default = {
        record = "dev-6-0-Reporting-elb.app"
        type = "A"
    }
}

resource "aws_route53_record" "Reporting-elb" {
  zone_id = "${var.existing_route53_zones.yourcareuniverse_net_id}"
  name = "${var.dns_elb_Reporting.record}"
  type = "${var.dns_elb_Reporting.type}"

  alias {
    name = "${aws_elb.Reporting.dns_name}"
    zone_id = "${aws_elb.Reporting.zone_id}"
    evaluate_target_health = false
  }
}


resource "aws_security_group" "Reporting_elb_security_group" {
    name = "${var.environment_name}-Reporting-elb"

    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["192.168.2.0/24"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    vpc_id = "${aws_vpc.application.id}"
    tags {
        Name        = "${var.environment_name}-Reporting-elb"
        Environment = "${var.environment_name}"
    }
}

resource "aws_elb" "Reporting" {
  name = "${var.environment_name}-Reporting"
  subnets = ["${aws_subnet.application-subnet-A-nat.id}", "${aws_subnet.application-subnet-C-nat.id}", "${aws_subnet.application-subnet-D-nat.id}", "${aws_subnet.application-subnet-E-nat.id}", ]
  security_groups = ["${aws_security_group.Reporting_elb_security_group.id}"]

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
    interval = 10
  }

  cross_zone_load_balancing = true
  idle_timeout = 60
  connection_draining = true
  connection_draining_timeout = 300

  tags {
    Name = "${var.environment_name}-Reporting"
  }
}
