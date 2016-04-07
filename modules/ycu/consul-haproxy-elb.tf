
variable "dns_elb_Consul-HAProxy" {
    default = {
        record = "dev-6-0-Consul-HAProxy-elb.app"
		type = "A"
    }
}


resource "aws_security_group" "Consul-HAProxy_elb_security_group" {
    name = "${var.environment_name}-Consul-HAProxy-elb"

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
        Name        = "${var.environment_name}-Consul-HAProxy-elb"
        Environment = "${var.environment_name}"
    }
}

resource "aws_elb" "Consul-HAProxy" {
  name = "${var.environment_name}-Consul-HAProxy"
  subnets = ["${aws_subnet.public-subnet-A-nat.id}", "${aws_subnet.public-subnet-C-nat.id}", "${aws_subnet.public-subnet-D-nat.id}", "${aws_subnet.public-subnet-E-nat.id}", ]
  security_groups = ["${aws_security_group.Consul-HAProxy_elb_security_group.id}"]

  listener {
    instance_port = 7001
    instance_protocol = "ssl"
    lb_port = 443
    lb_protocol = "ssl"
    ssl_certificate_id = "${var.elb_certs.developmentCertificate}"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 5
    target = "SSL:7001"
    interval = 6
  }

  cross_zone_load_balancing = true
  idle_timeout = 60
  connection_draining = true
  connection_draining_timeout = 300

  tags {
    Name = "${var.environment_name}-Consul-HAProxy"
  }
}
