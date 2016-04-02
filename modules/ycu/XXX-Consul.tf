elb-config.tf:resource "aws_elb" "Consul-HAProxy_elb" {
elb-config.tf:  name = "${var.environment_name}-Consul-HAProxy"
elb-config.tf:  security_groups = ["${aws_security_group.Consul-HAProxy_elb_security_group.id}"]
elb-config.tf:    Name = "${var.environment_name}-Consul-HAProxy"
elb-variables.tf:        Consul-HAProxy = "arn:aws:iam::678104714502:server-certificate/apiYourCareUniverseNet"
route53-config.tf:resource "aws_route53_record" "Consul-HAProxy-elb" {
route53-config.tf:  name = "${var.dns_elb_Consul-HAProxy.record}"
route53-config.tf:  type = "${var.dns_elb_Consul-HAProxy.type}"
route53-config.tf:    name = "${aws_elb.Consul-HAProxy_elb.dns_name}"
route53-config.tf:    zone_id = "${aws_elb.Consul-HAProxy_elb.zone_id}"
route53-variables.tf:variable "dns_elb_Consul-HAProxy" {
route53-variables.tf:        record = "dev-6-0-Consul-HAProxy-elb.app"
security_groups-config.tf:resource "aws_security_group" "Consul_security_group" {
security_groups-config.tf:    name = "${var.environment_name}-Consul"
security_groups-config.tf:        Name        = "${var.environment_name}-Consul"
security_groups-config.tf:resource "aws_security_group" "Consul-HAProxy_security_group" {
security_groups-config.tf:    name = "${var.environment_name}-Consul-HAProxy"
security_groups-config.tf:        security_groups = ["${aws_security_group.Consul-HAProxy_elb_security_group.id}"]
security_groups-config.tf:        Name        = "${var.environment_name}-Consul-HAProxy"
security_groups-config.tf:resource "aws_security_group" "Consul-HAProxy_elb_security_group" {
security_groups-config.tf:    name = "${var.environment_name}-Consul-HAProxy-elb"
security_groups-config.tf:        Name        = "${var.environment_name}-Consul-HAProxy-elb"
variable "Consul_ami_ids" {
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

variable "Consul_instance_types" {
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

resource "template_file" "Consul_user_data" {
  template = "${file("${path.module}/user-data.sh")}"

  vars {
    chef_role = "microservice-consul"
    domain = "${var.domain}"
    environment = "${var.environment}"
    chef_boot_bucket = "${var.chef_boot_bucket}"
    chef_config_bucket = "${var.chef_config_bucket}"
    consul_bucket = "${var.consul_bucket}"
    elasticsearch_boot_bucket = "${var.elasticsearch_boot_bucket}"
  }
}

Non-matching grp Consul

[  depends_on = ["aws_internet_gateway.services"] ]
[  depends_on = ["aws_internet_gateway.application"] ]

[  depends_on = ["aws_route.services_admin"]]
[  depends_on = ["aws_route.application_admin"]]

[  vpc_zone_identifier = ["${aws_subnet.services-subnet-A.id}", "${aws_subnet.services-subnet-C.id}", "${aws_subnet.services-subnet-D.id}", "${aws_subnet.services-subnet-E.id}"]]
[  vpc_zone_identifier = ["${aws_subnet.application-subnet-A.id}", "${aws_subnet.application-subnet-C.id}", "${aws_subnet.application-subnet-D.id}", "${aws_subnet.application-subnet-E.id}"]]

resource "aws_autoscaling_group" "Consul_group" {
  depends_on = ["aws_internet_gateway.ycu"]
s  #depends_on = ["aws_route.services_admin"]
  vpc_zone_identifier = ["${aws_subnet.services.*.id}"]
  name = "${var.environment}_YCU_Consul"
  max_size = "${lookup(var.default_asg_max, var.environment)}"
  min_size = "${lookup(var.default_asg_min, var.environment)}"
  health_check_grace_period = "${var.default_asg_health_check_period}"
  health_check_type = "${var.default_asg_health_check_type}"
  desired_capacity = "${lookup(var.default_asg_desired, var.environment)}"
  force_delete = true
  launch_configuration = "${aws_launch_configuration.Consul_configuration.id}"

  tag {
    key = "Name"
    value = "${var.environment}_YCU_Consul"
    propagate_at_launch = true
  }
}
Non-matching grp Consul

[	security_groups = ["${aws_security_group.microservices_security_group.id}", "${aws_security_group.consul-enabled-services_security_group.id}"]]
[	security_groups = ["${aws_security_group.XXX_security_group.id}"]]

resource "aws_launch_configuration" "Consul_configuration" {
  name                  = "${var.environment}_Consul"
  image_id              = "${coalesce(lookup(var.Consul_ami_ids, var.environment), lookup(var.default_ami_ids, var.environment))}"
  instance_type         = "${coalesce(lookup(var.Consul_instance_types, var.environment), lookup(var.default_instance_types, var.environment))}"
  key_name              = "${var.instance_key_name}"
  security_groups       = ["${aws_security_group.microservices.id}"]
  iam_instance_profile  = "${aws_iam_instance_profile.microservices_profile.name}"
  user_data             = "${template_file.Consul_user_data.rendered}"
}

