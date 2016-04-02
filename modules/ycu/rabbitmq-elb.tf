resource "aws_security_group" "RabbitMQ_elb" {
    name = "${var.environment_name}-RabbitMQ_elb"

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

    vpc_id = "${aws_vpc.application.id}"
    tags {
        Name        = "${var.environment_name}-RabbitMQ_elb"
        Environment = "${var.environment_name}"
    }
}

resource "aws_elb" "RabbitMQ_elb" {
  name = "${var.environment_name}-RabbitMQ"
  subnets = ["${aws_subnet.application-subnet-A-nat.id}", "${aws_subnet.application-subnet-C-nat.id}", "${aws_subnet.application-subnet-D-nat.id}", "${aws_subnet.application-subnet-E-nat.id}", ]
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
    Name = "${var.environment_name}-RabbitMQ"
  }
}

resource "aws_route53_record" "RabbitMQ-elb" {
  zone_id = "${var.existing_route53_zones.yourcareuniverse_net_id}"
  name = "${var.dns_elb_RabbitMQ.record}"
  type = "${var.dns_elb_RabbitMQ.type}"

  alias {
    name = "${aws_elb.RabbitMQ_elb.dns_name}"
    zone_id = "${aws_elb.RabbitMQ_elb.zone_id}"
    evaluate_target_health = false
  }
}
