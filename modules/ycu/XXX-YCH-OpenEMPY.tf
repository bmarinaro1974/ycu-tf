elb-config.tf:resource "aws_elb" "YCH-OpenEMPI_elb" {
elb-config.tf:  name = "${var.environment_name}-YCH-OpenEMPI"
elb-config.tf:  security_groups = ["${aws_security_group.YCH-OpenEMPI_elb_security_group.id}"]
elb-config.tf:    Name = "${var.environment_name}-YCH-OpenEMPI"
elb-variables.tf:        YCH-OpenEMPI = "arn:aws:iam::678104714502:server-certificate/ELBProdBaaOpenEMPI2016"
route53-config.tf:resource "aws_route53_record" "YCH-OpenEMPI-elb" {
route53-config.tf:  name = "${var.dns_elb_YCH-OpenEMPI.record}"
route53-config.tf:  type = "${var.dns_elb_YCH-OpenEMPI.type}"
route53-config.tf:    name = "${aws_elb.YCH-OpenEMPI_elb.dns_name}"
route53-config.tf:    zone_id = "${aws_elb.YCH-OpenEMPI_elb.zone_id}"
route53-variables.tf:variable "dns_elb_YCH-OpenEMPI" {
route53-variables.tf:        record = "dev-6-0-YCH-OpenEMPI-elb.app"
security_groups-config.tf:resource "aws_security_group" "YCH-OpenEMPI_elb_security_group" {
security_groups-config.tf:    name = "${var.environment_name}-YCH-OpenEMPI-elb"
security_groups-config.tf:        Name        = "${var.environment_name}-YCH-OpenEMPI-elb"
security_groups-config.tf:resource "aws_security_group" "YCH-OpenEMPI_security_group" {
security_groups-config.tf:    name = "${var.environment_name}-YCH-OpenEMPI"
security_groups-config.tf:        security_groups = ["${aws_security_group.YCH-OpenEMPI_elb_security_group.id}"]
security_groups-config.tf:        Name        = "${var.environment_name}-YCH-OpenEMPI"
variable "YCH-OpenEMPI_ami_ids" {
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

variable "YCH-OpenEMPI_instance_types" {
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

resource "template_file" "YCH-OpenEMPI_user_data" {
  template = "${file("${path.module}/user-data.sh")}"

  vars {
    chef_role = "microservice-ych-openempi"
    domain = "${var.domain}"
    environment = "${var.environment}"
    chef_boot_bucket = "${var.chef_boot_bucket}"
    chef_config_bucket = "${var.chef_config_bucket}"
    consul_bucket = "${var.consul_bucket}"
    elasticsearch_boot_bucket = "${var.elasticsearch_boot_bucket}"
  }
}

Non-matching grp YCH-OpenEMPI

[  depends_on = ["aws_internet_gateway.services"] ]
[  depends_on = ["aws_internet_gateway.application"] ]

[  depends_on = ["aws_route.services_admin"]]
[  depends_on = ["aws_route.application_admin"]]

[  vpc_zone_identifier = ["${aws_subnet.services-subnet-A.id}", "${aws_subnet.services-subnet-C.id}", "${aws_subnet.services-subnet-D.id}", "${aws_subnet.services-subnet-E.id}"]]
[  vpc_zone_identifier = ["${aws_subnet.application-subnet-A.id}", "${aws_subnet.application-subnet-C.id}", "${aws_subnet.application-subnet-D.id}", "${aws_subnet.application-subnet-E.id}"]]

[]
[  load_balancers = ["${aws_elb.XXX_elb.name}"]]

resource "aws_autoscaling_group" "YCH-OpenEMPI_group" {
  depends_on = ["aws_internet_gateway.ycu"]
  depends_on = ["aws_autoscaling_group.Consul_group"]
  #depends_on = ["aws_route.services_admin"]
  vpc_zone_identifier = ["${aws_subnet.services.*.id}"]
  name = "${var.environment}_YCH-OpenEMPI"
  max_size = "${lookup(var.default_asg_max, var.environment)}"
  min_size = "${lookup(var.default_asg_min, var.environment)}"
  health_check_grace_period = "${var.default_asg_health_check_period}"
  health_check_type = "${var.default_asg_health_check_type}"
  desired_capacity = "${lookup(var.default_asg_desired, var.environment)}"
  force_delete = true
  launch_configuration = "${aws_launch_configuration.YCH-OpenEMPI_configuration.id}"

  tag {
    key = "Name"
    value = "${var.environment}_YCH-OpenEMPI"
    propagate_at_launch = true
  }
}
Non-matching grp YCH-OpenEMPI

[	security_groups = ["${aws_security_group.microservices_security_group.id}", "${aws_security_group.consul-enabled-services_security_group.id}"]]
[	security_groups = ["${aws_security_group.XXX_security_group.id}", "${aws_security_group.consul-enabled-application_security_group.id}"]]

resource "aws_launch_configuration" "YCH-OpenEMPI_configuration" {
  name                  = "${var.environment}_YCH-OpenEMPI"
  image_id              = "${coalesce(lookup(var.YCH-OpenEMPI_ami_ids, var.environment), lookup(var.default_ami_ids, var.environment))}"
  instance_type         = "${coalesce(lookup(var.YCH-OpenEMPI_instance_types, var.environment), lookup(var.default_instance_types, var.environment))}"
  key_name              = "${var.instance_key_name}"
  security_groups       = ["${aws_security_group.microservices.id}"]
  iam_instance_profile  = "${aws_iam_instance_profile.microservices_profile.name}"
  user_data             = "${template_file.YCH-OpenEMPI_user_data.rendered}"
}

