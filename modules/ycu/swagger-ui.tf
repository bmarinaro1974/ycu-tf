variable "Swagger-UI_ami_ids" {
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

variable "Swagger-UI_instance_types" {
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

resource "template_file" "Swagger-UI_user_data" {
  template = "${file("${path.module}/user-data.sh")}"

  vars {
    chef_role = "microservice-swagger-ui"
    domain = "${var.domain}"
    environment = "${var.environment}"
    chef_boot_bucket = "${var.chef_boot_bucket}"
    chef_config_bucket = "${var.chef_config_bucket}"
    consul_bucket = "${var.consul_bucket}"
    elasticsearch_boot_bucket = "${var.elasticsearch_boot_bucket}"
  }
}

resource "aws_launch_configuration" "Swagger-UI_configuration" {
   name = "${var.environment}_Swagger-UI"
   image_id = "${var.ami_ids.Swagger-UI}"
   image_id = "${coalesce(lookup(var.Swagger-UI_ami_ids, var.environment), lookup(var.default_ami_ids, var.environment))}"
   instance_type = "${coalesce(lookup(var.Swagger-UI_instance_types, var.environment), lookup(var.default_instance_types, var.environment))}"
   key_name =  "${var.instance_key_name}"
   security_groups = ["${aws_security_group.microservices.id}"]
   iam_instance_profile = "${aws_iam_instance_profile.microservices_profile.name}"
   user_data = "${template_file.Swagger-UI_user_data.rendered}"

   lifecycle {
             create_before_destroy = true
   }
}

resource "aws_autoscaling_group" "Swagger-UI_group" {
  depends_on = ["aws_internet_gateway.ycu"]
  depends_on = ["aws_autoscaling_group.Consul_group"]
  #depends_on = ["aws_route.services_admin"]
  vpc_zone_identifier = ["${aws_subnet.services.*.id}"]
  name = "${var.environment}_YCE_Swagger_UI"
  max_size = "${lookup(var.default_asg_max, var.environment)}"
  min_size = "${lookup(var.default_asg_min, var.environment)}"
  health_check_grace_period = "${var.default_asg_health_check_period}"
  health_check_type = "${var.default_asg_health_check_type}"
  desired_capacity = "${lookup(var.default_asg_desired, var.environment)}"
  force_delete = true
  launch_configuration = "${aws_launch_configuration.Swagger-UI_configuration.id}"

  tag {
    key = "Name"
    value = "${var.environment}_YCE_Swagger-UI"
    propagate_at_launch = true
  }
}
