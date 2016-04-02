security_groups-config.tf:        security_groups = ["${aws_security_group.YCH_Portal_Worker_security_group.id}"]
security_groups-config.tf:resource "aws_security_group" "YCH_Portal_Worker_security_group" {
security_groups-config.tf:    name = "${var.environment_name}-YCH_Portal_Worker"
security_groups-config.tf:        Name        = "${var.environment_name}-YCH_Portal_Worker"
variable "YCH_Portal_Worker_ami_ids" {
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

variable "YCH_Portal_Worker_instance_types" {
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

resource "template_file" "YCH_Portal_Worker_user_data" {
  template = "${file("${path.module}/user-data.sh")}"

  vars {
    chef_role = "microservice-ych_portal_worker"
    domain = "${var.domain}"
    environment = "${var.environment}"
    chef_boot_bucket = "${var.chef_boot_bucket}"
    chef_config_bucket = "${var.chef_config_bucket}"
    consul_bucket = "${var.consul_bucket}"
    elasticsearch_boot_bucket = "${var.elasticsearch_boot_bucket}"
  }
}

Non-matching grp YCH_Portal_Worker

[  depends_on = ["aws_internet_gateway.services"] ]
[  depends_on = ["aws_internet_gateway.public"] ]

[  depends_on = ["aws_route.services_admin"]]
[  depends_on = ["aws_route.public_admin"]]

[  vpc_zone_identifier = ["${aws_subnet.services-subnet-A.id}", "${aws_subnet.services-subnet-C.id}", "${aws_subnet.services-subnet-D.id}", "${aws_subnet.services-subnet-E.id}"]]
[  vpc_zone_identifier = ["${aws_subnet.public-subnet-A.id}", "${aws_subnet.public-subnet-C.id}", "${aws_subnet.public-subnet-D.id}", "${aws_subnet.public-subnet-E.id}"]]

resource "aws_autoscaling_group" "YCH_Portal_Worker_group" {
  depends_on = ["aws_internet_gateway.ycu"]
  depends_on = ["aws_autoscaling_group.Consul_group"]
  #depends_on = ["aws_route.services_admin"]
  vpc_zone_identifier = ["${aws_subnet.services.*.id}"]
  name = "${var.environment}_YCH_Portal_Worker"
  max_size = "${lookup(var.default_asg_max, var.environment)}"
  min_size = "${lookup(var.default_asg_min, var.environment)}"
  health_check_grace_period = "${var.default_asg_health_check_period}"
  health_check_type = "${var.default_asg_health_check_type}"
  desired_capacity = "${lookup(var.default_asg_desired, var.environment)}"
  force_delete = true
  launch_configuration = "${aws_launch_configuration.YCH_Portal_Worker_configuration.id}"

  tag {
    key = "Name"
    value = "${var.environment}_YCH_Portal_Worker"
    propagate_at_launch = true
  }
}
Non-matching grp YCH_Portal_Worker

[	security_groups = ["${aws_security_group.microservices_security_group.id}", "${aws_security_group.consul-enabled-services_security_group.id}"]]
[	security_groups = ["${aws_security_group.XXX_security_group.id}", "${aws_security_group.consul-enabled-public_security_group.id}"]]

resource "aws_launch_configuration" "YCH_Portal_Worker_configuration" {
  name                  = "${var.environment}_YCH_Portal_Worker"
  image_id              = "${coalesce(lookup(var.YCH_Portal_Worker_ami_ids, var.environment), lookup(var.default_ami_ids, var.environment))}"
  instance_type         = "${coalesce(lookup(var.YCH_Portal_Worker_instance_types, var.environment), lookup(var.default_instance_types, var.environment))}"
  key_name              = "${var.instance_key_name}"
  security_groups       = ["${aws_security_group.microservices.id}"]
  iam_instance_profile  = "${aws_iam_instance_profile.microservices_profile.name}"
  user_data             = "${template_file.YCH_Portal_Worker_user_data.rendered}"
}

