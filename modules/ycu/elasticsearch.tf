variable "Elasticsearch_ami_ids" {
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

variable "Elasticsearch_instance_types" {
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

resource "aws_security_group" "Elasticsearch_elb" {
  name = "${var.environment}-Elasticsearch-elb"

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
  #vpc_id = "${aws_vpc.ycu.id}"
  vpc_id = "${aws_vpc.ycu.id}"

  tags {
    Name        = "${var.environment}-Elasticsearch-elb"
    Environment = "${var.environment}"
  }
}

resource "aws_elb" "Elasticsearch" {
  name = "${var.environment}-Elasticsearch"
  subnets = ["${aws_subnet.application.*.id}"]
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
    Name = "${var.environment}-Elasticsearch"
  }
}

variable "dns_elb_Elasticsearch" {
  default = {
    record = "dev-6-0-Elasticsearch-elb.app"
    type = "A"
  }
}

resource "aws_route53_record" "Elasticsearch-elb" {
  zone_id = "${var.existing_route53_zones.yourcareuniverse_net_id}"
  name = "${var.dns_elb_Elasticsearch.record}"
  type = "${var.dns_elb_Elasticsearch.type}"

  alias {
    name = "${aws_elb.Elasticsearch.dns_name}"
    zone_id = "${aws_elb.Elasticsearch.zone_id}"
    evaluate_target_health = false
  }
}


resource "template_file" "Elasticsearch_user_data" {
  template = "${file("${path.module}/user-data.sh")}"

  vars {
    chef_role = "microservice-elasticsearch"
    domain = "${var.domain}"
    environment = "${var.environment}"
    chef_boot_bucket = "${var.chef_boot_bucket}"
    chef_config_bucket = "${var.chef_config_bucket}"
    consul_bucket = "${var.consul_bucket}"
    elasticsearch_boot_bucket = "${var.elasticsearch_boot_bucket}"
  }
}

resource "aws_security_group" "Elasticsearch" {
    name = "${var.environment}-Elasticsearch"

    ingress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      self = "true"
    }
   
   ingress {
       from_port = 9200
       to_port = 9300
       protocol = "tcp"
       security_groups = ["${aws_security_group.Elasticsearch_elb.id}"]
   }
   ingress {
       from_port = 9200
       to_port = 9300
       protocol = "tcp"
       security_groups = ["${aws_security_group.logstash.id}"]
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

   ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["${var.workspaces_cidr_block}"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ### XXX: application VPC
    #vpc_id = "${aws_vpc.ycu.id}"
    vpc_id = "${aws_vpc.ycu.id}"

    tags {
        Name        = "${var.environment}-Elasticsearch"
        Environment = "${var.environment}"
    }
}

resource "aws_autoscaling_group" "Elasticsearch_group" {
  depends_on = ["aws_internet_gateway.ycu"]
  #depends_on = ["aws_route.services_admin"]
  vpc_zone_identifier = ["${aws_subnet.application.*.id}"]
  name = "${var.environment}_YCU_Elasticsearch"
  max_size = "${lookup(var.default_asg_max, var.environment)}"
  min_size = "${lookup(var.default_asg_min, var.environment)}"
  health_check_grace_period = "${var.default_asg_health_check_period}"
  health_check_type = "${var.default_asg_health_check_type}"
  desired_capacity = "${lookup(var.default_asg_desired, var.environment)}"
  force_delete = true
  launch_configuration = "${aws_launch_configuration.Elasticsearch_configuration.id}"
  load_balancers = ["${aws_elb.Elasticsearch.name}"]

  tag {
    key = "Name"
    value = "${var.environment}_YCU_Elasticsearch"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "Elasticsearch_configuration" {
  name                  = "${var.environment}_Elasticsearch"
  image_id              = "${coalesce(lookup(var.Elasticsearch_ami_ids, var.environment), lookup(var.default_ami_ids, var.environment))}"
  instance_type         = "${coalesce(lookup(var.Elasticsearch_instance_types, var.environment), lookup(var.default_instance_types, var.environment))}"
  key_name              = "${var.instance_key_name}"
  security_groups       = ["${aws_security_group.Elasticsearch.id}"]
  iam_instance_profile  = "${aws_iam_instance_profile.microservices_profile.name}"
  user_data             = "${template_file.Elasticsearch_user_data.rendered}"
}

