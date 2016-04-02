elb-config.tf:resource "aws_elb" "YCU-Direct_elb" {
elb-config.tf:  name = "${var.environment_name}-YCU-Direct"
elb-config.tf:  security_groups = ["${aws_security_group.YCU-Direct_elb_security_group.id}"]
elb-config.tf:    Name = "${var.environment_name}-YCU-Direct"
elb-config.tf:resource "aws_elb" "YCU-Direct-Internal_elb" {
elb-config.tf:  name = "${var.environment_name}-YCU-Direct-Internal"
elb-config.tf:  security_groups = ["${aws_security_group.YCU-Direct-Internal_elb_security_group.id}"]
elb-config.tf:    Name = "${var.environment_name}-YCU-Direct-Internal"
elb-variables.tf:        YCU-Direct = "arn:aws:iam::678104714502:server-certificate/ELBProdPublicDirect"
route53-config.tf:resource "aws_route53_record" "YCU-Direct-elb" {
route53-config.tf:  name = "${var.dns_elb_YCU-Direct.record}"
route53-config.tf:  type = "${var.dns_elb_YCU-Direct.type}"
route53-config.tf:    name = "${aws_elb.YCU-Direct_elb.dns_name}"
route53-config.tf:    zone_id = "${aws_elb.YCU-Direct_elb.zone_id}"
route53-variables.tf:variable "dns_elb_YCU-Direct" {
route53-variables.tf:        record = "dev-6-0-YCU-Direct-elb.app"
security_groups-config.tf:resource "aws_security_group" "YCU-Direct_elb_security_group" {
security_groups-config.tf:    name = "${var.environment_name}-YCU-Direct-elb"
security_groups-config.tf:        Name        = "${var.environment_name}-YCU-Direct-elb"
security_groups-config.tf:resource "aws_security_group" "YCU-Direct-Internal_elb_security_group" {
security_groups-config.tf:    name = "${var.environment_name}-YCU-Direct-Internal-elb"
security_groups-config.tf:        Name        = "${var.environment_name}-YCU-Direct-Internal-elb"
security_groups-config.tf:resource "aws_security_group" "YCU-Direct_security_group" {
security_groups-config.tf:    name = "${var.environment_name}-YCU-Direct"
security_groups-config.tf:        security_groups = ["${aws_security_group.YCU-Direct_elb_security_group.id}"]
security_groups-config.tf:        Name        = "${var.environment_name}-YCU-Direct"
variable "YCU-Direct_ami_ids" {
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

variable "YCU-Direct_instance_types" {
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

resource "template_file" "YCU-Direct_user_data" {
  template = "${file("${path.module}/user-data.sh")}"

  vars {
    chef_role = "microservice-ycu-direct"
    domain = "${var.domain}"
    environment = "${var.environment}"
    chef_boot_bucket = "${var.chef_boot_bucket}"
    chef_config_bucket = "${var.chef_config_bucket}"
    consul_bucket = "${var.consul_bucket}"
    elasticsearch_boot_bucket = "${var.elasticsearch_boot_bucket}"
  }
}

Non-matching grp YCU-Direct

[  depends_on = ["aws_internet_gateway.services"] ]
[  depends_on = ["aws_internet_gateway.public"] ]

[  depends_on = ["aws_route.services_admin"]]
[  depends_on = ["aws_route.public_admin"]]

[  vpc_zone_identifier = ["${aws_subnet.services-subnet-A.id}", "${aws_subnet.services-subnet-C.id}", "${aws_subnet.services-subnet-D.id}", "${aws_subnet.services-subnet-E.id}"]]
[  vpc_zone_identifier = ["${aws_subnet.public-subnet-A.id}", "${aws_subnet.public-subnet-C.id}", "${aws_subnet.public-subnet-D.id}", "${aws_subnet.public-subnet-E.id}"]]

[]
[  load_balancers = ["${aws_elb.XXX_elb.name}", "${aws_elb.XXX-Internal_elb.name}"]]


resource "aws_autoscaling_group" "YCU-Direct_group" {
  depends_on = ["aws_internet_gateway.ycu"]
  depends_on = ["aws_autoscaling_group.Consul_group"]
  #depends_on = ["aws_route.services_admin"]
  vpc_zone_identifier = ["${aws_subnet.services.*.id}"]
  name = "${var.environment}_YCU-Direct"
  max_size = "${lookup(var.default_asg_max, var.environment)}"
  min_size = "${lookup(var.default_asg_min, var.environment)}"
  health_check_grace_period = "${var.default_asg_health_check_period}"
  health_check_type = "${var.default_asg_health_check_type}"
  desired_capacity = "${lookup(var.default_asg_desired, var.environment)}"
  force_delete = true
  launch_configuration = "${aws_launch_configuration.YCU-Direct_configuration.id}"

  tag {
    key = "Name"
    value = "${var.environment}_YCU-Direct"
    propagate_at_launch = true
  }
}
Non-matching grp YCU-Direct

[	security_groups = ["${aws_security_group.microservices_security_group.id}", "${aws_security_group.consul-enabled-services_security_group.id}"]]
[	security_groups = ["${aws_security_group.XXX_security_group.id}", "${aws_security_group.consul-enabled-public_security_group.id}"]]

resource "aws_launch_configuration" "YCU-Direct_configuration" {
  name                  = "${var.environment}_YCU-Direct"
  image_id              = "${coalesce(lookup(var.YCU-Direct_ami_ids, var.environment), lookup(var.default_ami_ids, var.environment))}"
  instance_type         = "${coalesce(lookup(var.YCU-Direct_instance_types, var.environment), lookup(var.default_instance_types, var.environment))}"
  key_name              = "${var.instance_key_name}"
  security_groups       = ["${aws_security_group.microservices.id}"]
  iam_instance_profile  = "${aws_iam_instance_profile.microservices_profile.name}"
  user_data             = "${template_file.YCU-Direct_user_data.rendered}"
}

