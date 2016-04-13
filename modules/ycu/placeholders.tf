resource "aws_security_group" "Prod_Public_Portal_security_group" {
  name = "${var.environment}-prod-public-portal"

  ########## THIS IS A PLACEHOLDER ##############

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    self = "true"
  }

  vpc_id = "${aws_vpc.ycu.id}"
  tags {
    Name        = "${var.environment}-prod-public-portal"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group" "logstash_security_group" {
  name = "${var.environment}-logstash"

  ########## THIS IS A PLACEHOLDER ##############

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    self = "true"
  }

  vpc_id = "${aws_vpc.ycu.id}"
  tags {
    Name        = "${var.environment}-logstash"
    Environment = "${var.environment}"
  }
}