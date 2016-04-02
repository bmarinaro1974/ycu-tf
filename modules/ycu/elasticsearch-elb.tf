resource "aws_security_group" "Elasticsearch_elb" {
    name = "${var.environment_name}-Elasticsearch-elb"

    ingress {
       from_port = 9300
       to_port = 9300
       protocol = "tcp"
       cidr_blocks = ["${var.mercury_cidr_block}"]
   }
   ingress {
       from_port = 9200
       to_port = 9300
       protocol = "tcp"
       cidr_blocks = ["${var.venus_cidr_block}"]
   }
   ingress {
       from_port = 9200
       to_port = 9300
       protocol = "tcp"
       cidr_blocks = ["${var.earth_cidr_block}"]
   }
   ingress {
       from_port = 9200
       to_port = 9300
       protocol = "tcp"
       cidr_blocks = ["${var.mars_cidr_block}"]
   }
   ingress {
       from_port = 9200
       to_port = 9300
       protocol = "tcp"
       cidr_blocks = ["${var.workspaces_cidr_block}"]
   }
   ingress {
       from_port = 9200
       to_port = 9300
       protocol = "tcp"
       cidr_blocks = ["${var.jupiter_cidr_block}"]
   }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    #XXX: Do not have an application VPC
    #vpc_id = "${aws_vpc.application.id}"
    vpc_id = "${aws_vpc.ycu.id}"

    tags {
        Name        = "${var.environment_name}-Elasticsearch-elb"
        Environment = "${var.environment_name}"
    }
}

resource "aws_elb" "Elasticsearch_elb" {
  name = "${var.environment_name}-Elasticsearch"
  subnets = ["${aws_subnet.application-subnet-A-nat.id}", "${aws_subnet.application-subnet-C-nat.id}", "${aws_subnet.application-subnet-D-nat.id}", "${aws_subnet.application-subnet-E-nat.id}"]
  security_groups = ["${aws_security_group.Elasticsearch_elb.id}"]
  internal = true

  listener {
    instance_port = 9200
    instance_protocol = "tcp"
    lb_port = 9200
    lb_protocol = "tcp"
  }
  
  listener {
    instance_port = 9300
    instance_protocol = "tcp"
    lb_port = 9300
    lb_protocol = "tcp"
  }

  health_check {
    healthy_threshold = 10
    unhealthy_threshold = 2
    timeout = 5
    target = "SSL:9200"
    interval = 30
  }

  cross_zone_load_balancing = true
  idle_timeout = 60
  connection_draining = true
  connection_draining_timeout = 300

  tags {
    Name = "${var.environment_name}-Elasticsearch"
  }
}


resource "aws_route53_record" "Elasticsearch-elb" {
  zone_id = "${var.existing_route53_zones.yourcareuniverse_net_id}"
  name = "${var.dns_elb_Elasticsearch.record}"
  type = "${var.dns_elb_Elasticsearch.type}"

  alias {
    name = "${aws_elb.Elasticsearch_elb.dns_name}"
    zone_id = "${aws_elb.Elasticsearch_elb.zone_id}"
    evaluate_target_health = false
  }
}
