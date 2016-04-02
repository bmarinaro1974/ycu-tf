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
    name = "${var.environment_name}-Elasticsearch"

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
    #vpc_id = "${aws_vpc.application.id}"
    vpc_id = "${aws_vpc.ycu.id}"

    tags {
        Name        = "${var.environment_name}-Elasticsearch"
        Environment = "${var.environment_name}"
    }
}

resource "aws_autoscaling_group" "Elasticsearch_group" {
  depends_on = ["aws_internet_gateway.ycu"]
s  #depends_on = ["aws_route.services_admin"]
  vpc_zone_identifier = ["${aws_subnet.applications.*.id}"]
  name = "${var.environment}_YCU_Elasticsearch"
  max_size = "${lookup(var.default_asg_max, var.environment)}"
  min_size = "${lookup(var.default_asg_min, var.environment)}"
  health_check_grace_period = "${var.default_asg_health_check_period}"
  health_check_type = "${var.default_asg_health_check_type}"
  desired_capacity = "${lookup(var.default_asg_desired, var.environment)}"
  force_delete = true
  launch_configuration = "${aws_launch_configuration.Elasticsearch_configuration.id}"
  load_balancers = ["${aws_elb.Elasticsearch_elb.name}"]

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
  security_groups       = ["${aws_security_group.elasticsearch.id}"]
  iam_instance_profile  = "${aws_iam_instance_profile.microservices_profile.name}"
  user_data             = "${template_file.Elasticsearch_user_data.rendered}"
}

