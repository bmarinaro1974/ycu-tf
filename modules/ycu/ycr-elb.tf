
resource "aws_security_group" "YCR_elb_security_group" {
    name = "${var.environment_name}-YCR-elb"

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

    vpc_id = "${aws_vpc.public.id}"
    tags {
        Name        = "${var.environment_name}-YCR-elb"
        Environment = "${var.environment_name}"
    }
}

resource "aws_elb" "YCR" {
  name = "${var.environment_name}-YCR"
  subnets = ["${aws_subnet.public-subnet-A-nat.id}", "${aws_subnet.public-subnet-C-nat.id}", "${aws_subnet.public-subnet-D-nat.id}", "${aws_subnet.public-subnet-E-nat.id}", ]
  security_groups = ["${aws_security_group.YCR_elb_security_group.id}"]

  listener {
    instance_port = 8682
    instance_protocol = "https"
    lb_port = 443
    lb_protocol = "https"
    ssl_certificate_id = "${var.elb_certs.developmentCertificate}"
  }
  listener {
    instance_port = 8682
    instance_protocol = "https"
    lb_port = 80
    lb_protocol = "http"
    ssl_certificate_id = "${var.elb_certs.developmentCertificate}"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 5
    target = "HTTPS:8682/users/sign_in"
    interval = 6
  }

  cross_zone_load_balancing = true
  idle_timeout = 60
  connection_draining = true
  connection_draining_timeout = 300

  tags {
    Name = "${var.environment_name}-YCR"
  }
}


variable "dns_elb_YCR" {
    default = {
        record = "dev-6-0-YCR-elb.app"
        type = "A"
    }
}

resource "aws_route53_record" "YCR-elb" {
  zone_id = "${var.existing_route53_zones.yourcareuniverse_net_id}"
  name = "${var.dns_elb_YCR.record}"
  type = "${var.dns_elb_YCR.type}"

  alias {
    name = "${aws_elb.YCR.dns_name}"
    zone_id = "${aws_elb.YCR.zone_id}"
    evaluate_target_health = false
  }
}