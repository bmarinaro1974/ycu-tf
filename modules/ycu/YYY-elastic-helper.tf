
resource "aws_security_group" "Elasticsearch_elb" {
    name = "${var.environment_name}-Elasticsearch-elb"

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
    #vpc_id = "${aws_vpc.application.id}"
    vpc_id = "${aws_vpc.ycu.id}"

    tags {
        Name        = "${var.environment_name}-Elasticsearch-elb"
        Environment = "${var.environment_name}"
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
