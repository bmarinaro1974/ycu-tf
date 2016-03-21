resource "aws_vpc" "ycu" {
  cidr_block = "${module.network.env_cidr_block}"
  instance_tenancy = "${lookup(var.instance_tenancy, var.environment)}"

  tags{
    Name="${var.environment}-vpc-ycu"
    Environment="${var.environment}"
  }
}

resource "aws_internet_gateway" "ycu" {
  vpc_id = "${aws_vpc.ycu.id}"
  tags{
    Name="${var.environment}-igw-ycu"
    Environment="${var.environment}"
  }
}

resource "aws_eip" "nat" {
  depends_on = ["aws_internet_gateway.ycu"]
  count = 3
  vpc = true
}

resource "aws_nat_gateway" "ycu" {
  depends_on = ["aws_internet_gateway.ycu"]
  count = 3
  allocation_id = "${element(aws_eip.nat.*.id, count.index)}"
  subnet_id = "${element(aws_subnet.pub.*.id, count.index)}"
}

resource "aws_route_table" "ycu" {
  vpc_id = "${aws_vpc.ycu.id}"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.ycu.0.id}"
  }

  tags {
    Name        = "${var.environment}-nat-${count.index}-subnet-route-table"
    Environment = "${var.environment}"
  }
}

resource "aws_main_route_table_association" "ycu" {
  vpc_id = "${aws_vpc.ycu.id}"
  route_table_id = "${aws_route_table.ycu.id}"
}

resource "aws_route53_zone" "ycu" {
  name = "${var.environment}.yourcareuniverse.net"

  tags {
    Name = "${var.environment}.yourcareuniverse.net"
    Environment = "${var.environment}"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "template_file" "log_policy" {
  template = "${file("${path.module}/log-bucket-policy.json")}"

  vars {
    log_bucket_arn = "arn:aws:s3:::${var.environment}-ycu-vpc-log-bucket"
    elb_logging_arn = "arn:aws:iam::${lookup(var.elb_logging_account, var.region)}:root"
  }
}

resource "aws_s3_bucket" "log" {
  bucket = "${var.environment}-ycu-vpc-log-bucket"
  acl = "log-delivery-write"
  policy = "${template_file.log_policy.rendered}"
}
