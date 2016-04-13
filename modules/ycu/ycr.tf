variable "YCR_ami_ids" {
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

variable "YCR_instance_types" {
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


resource "aws_security_group" "YCR_elb_security_group" {
  name = "${var.environment}-YCR-elb"

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
    Name        = "${var.environment}-YCR-elb"
    Environment = "${var.environment}"
  }
}

resource "aws_elb" "YCR" {
  name = "${var.environment}-YCR"
  subnets = ["${aws_subnet.pub.*.id}"]
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
    Name = "${var.environment}-YCR"
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

resource "template_file" "YCR_user_data" {
  template = "${file("${path.module}/user-data.sh")}"

  vars {
    chef_role = "microservice-ycr"
    domain = "${var.domain}"
    environment = "${var.environment}"
    chef_boot_bucket = "${var.chef_boot_bucket}"
    chef_config_bucket = "${var.chef_config_bucket}"
    consul_bucket = "${var.consul_bucket}"
    elasticsearch_boot_bucket = "${var.elasticsearch_boot_bucket}"
  }
}

resource "aws_autoscaling_group" "YCR_group" {
  # XXX: gateway: public
  depends_on = ["aws_internet_gateway.ycu"]
  depends_on = ["aws_autoscaling_group.Consul_group"]
  #depends_on = ["aws_route.public_admin"]
  vpc_zone_identifier = ["${aws_subnet.pub.*.id}"]
  name = "${var.environment}_YCR"
  max_size = "${lookup(var.default_asg_max, var.environment)}"
  min_size = "${lookup(var.default_asg_min, var.environment)}"
  health_check_grace_period = "${var.default_asg_health_check_period}"
  health_check_type = "${var.default_asg_health_check_type}"
  desired_capacity = "${lookup(var.default_asg_desired, var.environment)}"
  force_delete = true
  launch_configuration = "${aws_launch_configuration.YCR_configuration.id}"
  load_balancers = ["${aws_elb.YCR.name}"]
 
  tag {
    key = "Name"
    value = "${var.environment}_YCR"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "YCR_configuration" {
  name                  = "${var.environment}_YCR"
  image_id              = "${coalesce(lookup(var.YCR_ami_ids, var.environment), lookup(var.default_ami_ids, var.environment))}"
  instance_type         = "${coalesce(lookup(var.YCR_instance_types, var.environment), lookup(var.default_instance_types, var.environment))}"
  key_name              = "${var.instance_key_name}"
  #XXX: Consul-enabled public security is that a thing (I think so)
  security_groups       = ["${aws_security_group.YCR.id}","${aws_security_group.consul.id}" ]
  iam_instance_profile  = "${aws_iam_instance_profile.microservices_profile.name}"
  user_data             = "${template_file.YCR_user_data.rendered}"
}

