elb-config.tf:resource "aws_elb" "RabbitMQ_elb" {
elb-config.tf:  name = "${var.environment_name}-RabbitMQ"
elb-config.tf:  security_groups = ["${aws_security_group.RabbitMQ_elb_security_group.id}", "${aws_security_group.RabbitMQ-access_security_group.id}"]
elb-config.tf:    Name = "${var.environment_name}-RabbitMQ"
route53-config.tf:resource "aws_route53_record" "RabbitMQ-elb" {
route53-config.tf:  name = "${var.dns_elb_RabbitMQ.record}"
route53-config.tf:  type = "${var.dns_elb_RabbitMQ.type}"
route53-config.tf:    name = "${aws_elb.RabbitMQ_elb.dns_name}"
route53-config.tf:    zone_id = "${aws_elb.RabbitMQ_elb.zone_id}"
route53-variables.tf:variable "dns_elb_RabbitMQ" {
route53-variables.tf:        record = "dev-6-0-RabbitMQ-elb.app"
security_groups-config.tf:resource "aws_security_group" "RabbitMQ_security_group" {
security_groups-config.tf:    name = "${var.environment_name}-RabbitMQ"
security_groups-config.tf:        security_groups = ["${aws_security_group.RabbitMQ_elb_security_group.id}"]
security_groups-config.tf:        Name        = "${var.environment_name}-RabbitMQ"
security_groups-config.tf:resource "aws_security_group" "RabbitMQ_elb_security_group" {
security_groups-config.tf:    name = "${var.environment_name}-RabbitMQ_elb"
security_groups-config.tf:        Name        = "${var.environment_name}-RabbitMQ_elb"
security_groups-config.tf:resource "aws_security_group" "RabbitMQ-access_security_group" {
security_groups-config.tf:    name = "${var.environment_name}-RabbitMQ-access"
security_groups-config.tf:        security_groups = ["${aws_security_group.RabbitMQ_security_group.id}"]
security_groups-config.tf:        security_groups = ["${aws_security_group.RabbitMQ_elb_security_group.id}"]
security_groups-config.tf:        Name        = "${var.environment_name}-RabbitMQ-access"
variable "RabbitMQ_ami_ids" {
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

variable "RabbitMQ_instance_types" {
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

resource "template_file" "RabbitMQ_user_data" {
  template = "${file("${path.module}/user-data.sh")}"

  vars {
    chef_role = "microservice-rabbitmq"
    domain = "${var.domain}"
    environment = "${var.environment}"
    chef_boot_bucket = "${var.chef_boot_bucket}"
    chef_config_bucket = "${var.chef_config_bucket}"
    consul_bucket = "${var.consul_bucket}"
    elasticsearch_boot_bucket = "${var.elasticsearch_boot_bucket}"
  }
}

Non-matching grp RabbitMQ

[  depends_on = ["aws_internet_gateway.services"] ]
[  depends_on = ["aws_internet_gateway.application"] ]

[  depends_on = ["aws_autoscaling_group.Consul_group"] ]
[  depends_on = ["aws_route.application_admin"]]

[  depends_on = ["aws_route.services_admin"]]
[  [blank]]

[  vpc_zone_identifier = ["${aws_subnet.services-subnet-A.id}", "${aws_subnet.services-subnet-C.id}", "${aws_subnet.services-subnet-D.id}", "${aws_subnet.services-subnet-E.id}"]]
[  vpc_zone_identifier = ["${aws_subnet.application-subnet-A.id}", "${aws_subnet.application-subnet-C.id}", "${aws_subnet.application-subnet-D.id}", "${aws_subnet.application-subnet-E.id}"]]

[  [xxxxx load balancers?]]
[  load_balancers = ["${aws_elb.XXX_elb.name}"]]

resource "aws_autoscaling_group" "RabbitMQ_group" {
  depends_on = ["aws_internet_gateway.ycu"]
  depends_on = ["aws_autoscaling_group.Consul_group"]
  #depends_on = ["aws_route.services_admin"]
  vpc_zone_identifier = ["${aws_subnet.services.*.id}"]
  name = "${var.environment}_YCU_RabbitMQ"
  max_size = "${lookup(var.default_asg_max, var.environment)}"
  min_size = "${lookup(var.default_asg_min, var.environment)}"
  health_check_grace_period = "${var.default_asg_health_check_period}"
  health_check_type = "${var.default_asg_health_check_type}"
  desired_capacity = "${lookup(var.default_asg_desired, var.environment)}"
  force_delete = true
  launch_configuration = "${aws_launch_configuration.RabbitMQ_configuration.id}"

  tag {
    key = "Name"
    value = "${var.environment}_YCU_RabbitMQ"
    propagate_at_launch = true
  }
}
Non-matching grp RabbitMQ

[	security_groups = ["${aws_security_group.microservices_security_group.id}", "${aws_security_group.consul-enabled-services_security_group.id}"]]
[	security_groups = ["${aws_security_group.XXX_security_group.id}", "${aws_security_group.XXX-access_security_group.id}"]]

resource "aws_launch_configuration" "RabbitMQ_configuration" {
  name                  = "${var.environment}_RabbitMQ"
  image_id              = "${coalesce(lookup(var.RabbitMQ_ami_ids, var.environment), lookup(var.default_ami_ids, var.environment))}"
  instance_type         = "${coalesce(lookup(var.RabbitMQ_instance_types, var.environment), lookup(var.default_instance_types, var.environment))}"
  key_name              = "${var.instance_key_name}"
  security_groups       = ["${aws_security_group.microservices.id}"]
  iam_instance_profile  = "${aws_iam_instance_profile.microservices_profile.name}"
  user_data             = "${template_file.RabbitMQ_user_data.rendered}"
}

