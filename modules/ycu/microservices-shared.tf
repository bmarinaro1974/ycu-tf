resource "aws_security_group" "microservices" {
  name = "${var.environment}-microservices"

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    self = "true"
  }

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["${var.admin_cidr_block}"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${var.workspaces_cidr_block}"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["${var.workspaces_cidr_block}"]
  }

  /*ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    security_groups = ["${aws_security_group.YCR.id}"]
  }

  ingress {
    from_port = 4700
    to_port = 4799
    protocol = "tcp"
    security_groups = ["${aws_security_group.YCU-Direct.id}"]
  }
  ingress {
    from_port = 4700
    to_port = 4799
    protocol = "tcp"
    security_groups = ["${aws_security_group.HAProxy.id}"]
  }
  ingress {
    from_port = 4700
    to_port = 4799
    protocol = "tcp"
    security_groups = ["${aws_security_group.YCH-CM.id}"]
  }
  ingress {
    from_port = 4700
    to_port = 4799
    protocol = "tcp"
    security_groups = ["${aws_security_group.YCR.id}"]
  }

  ingress {
    from_port = 8300
    to_port = 8302
    protocol = "tcp"
    cidr_blocks = ["${var.svc_cidr_block}"]
  }*/

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = "${aws_vpc.ycu.id}"
  tags {
    Name        = "${var.environment}-microservices"
    Environment = "${var.environment}"
  }
}


resource "aws_security_group" "consul-enabled" {
  name = "${var.environment}-consul-enabled"


  /*ingress {
    from_port = 8300
    to_port = 8302
    protocol = "udp"
    security_groups = ["${aws_security_group.Logstash.id}"]
  }
  ingress {
    from_port = 8300
    to_port = 8302
    protocol = "udp"
    security_groups = ["${aws_security_group.YCU-Direct.id}"]
  }
  ingress {
    from_port = 8300
    to_port = 8302
    protocol = "udp"
    security_groups = ["${aws_security_group.YCH-CM.id}"]
  }
  ingress {
    from_port = 8300
    to_port = 8302
    protocol = "udp"
    security_groups = ["${aws_security_group.YCR.id}"]
  }
  ingress {
    from_port = 8300
    to_port = 8302
    protocol = "udp"
    security_groups = ["${aws_security_group.Spago.id}"]
  }
  ingress {
    from_port = 8300
    to_port = 8302
    protocol = "udp"
    security_groups = ["${aws_security_group.HAProxy.id}"]
  }
  ingress {
    from_port = 8300
    to_port = 8302
    protocol = "udp"
    security_groups = ["${aws_security_group.MS.id}"]
  }
  ingress {
    from_port = 8300
    to_port = 8302
    protocol = "udp"
    security_groups = ["${aws_security_group.Consul.id}"]
  }
  ingress {
    from_port = 8300
    to_port = 8302
    protocol = "udp"
    security_groups = ["${aws_security_group.OpenEMPI.id}"]
  }

  ingress {
    from_port = 8301
    to_port = 8301
    protocol = "tcp"
    security_groups = ["${aws_security_group.Logstash.id}"]
  }
  ingress {
    from_port = 8301
    to_port = 8301
    protocol = "tcp"
    security_groups = ["${aws_security_group.YCU-Direct.id}"]]
  }
  ingress {
    from_port = 8301
    to_port = 8301
    protocol = "tcp"
    security_groups = ["${aws_security_group.YCH-CM.id}"]
  }
  ingress {
    from_port = 8301
    to_port = 8301
    protocol = "tcp"
    security_groups = ["${aws_security_group.YCR.id}"]
  }
  ingress {
    from_port = 8301
    to_port = 8301
    protocol = "tcp"
    security_groups = ["${aws_security_group.Spago.id}"]
  }
  ingress {
    from_port = 8301
    to_port = 8301
    protocol = "tcp"
    security_groups = ["${aws_security_group.HAProxy.id}"]
  }
  ingress {
    from_port = 8301
    to_port = 8301
    protocol = "tcp"
    security_groups = ["${aws_security_group.MS.id}"]
  }
  ingress {
    from_port = 8301
    to_port = 8301
    protocol = "tcp"
    security_groups = ["${aws_security_group.Consul.id}"]
  }
  ingress {
    from_port = 8301
    to_port = 8301
    protocol = "tcp"
    security_groups = ["${aws_security_group.OpenEMPI.id}"]
  }*/


  vpc_id = "${aws_vpc.ycu.id}"
  tags {
    Name        = "${var.environment}-consul-enabled"
    Environment = "${var.environment}"
  }
}


resource "template_file" "microservices_policy" {
  template = "${file("${path.module}/microservices-policy.json")}"

  vars {
    chef_boot_bucket_arn = "arn:aws:s3:::${var.chef_boot_bucket}"
    chef_config_bucket_arn = "arn:aws:s3:::${var.chef_config_bucket}"
    consul_bucket_arn = "arn:aws:s3:::${var.consul_bucket}"
    elasticsearch_boot_bucket_arn = "arn:aws:s3:::${var.elasticsearch_boot_bucket}"
  }
}

resource "aws_iam_role" "microservices" {
  name = "${var.environment}-microservices"
  assume_role_policy = "${file("${path.module}/assume-role-policy.json")}"
}

resource "aws_iam_role_policy" "microservices" {
  name = "${var.environment}-microservices"
  role = "${aws_iam_role.microservices.id}"
  policy = "${template_file.microservices_policy.rendered}"
}

resource "aws_iam_instance_profile" "microservices_profile" {
  name = "${var.environment}-microservices-profile"
  roles = ["${aws_iam_role.microservices.name}"]
}