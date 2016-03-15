resource "aws_vpc" "ycu" {
  cidr_block = "${module.network.env_cidr_block}"
  instance_tenancy = "${lookup(var.instance_tenancy, var.env)}"

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
  vpc = true
}

resource "aws_nat_gateway" "ycu" {
  depends_on = ["aws_internet_gateway.ycu"]
  allocation_id = "${aws_eip.nat.id}"
  subnet_id = "${aws_subnet.pub.0.id}"
}

resource "aws_route_table" "ycu" {
  vpc_id = "${aws_vpc.ycu.id}"

  route{
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.ycu.id}"
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

  }
}

resource "aws_s3_bucket" "log" {
  bucket = "${var.environment}-ycu-vpc-log-bucket"
  acl = "log-delivery-write"
  policy = "${template_file.log_policy.rendered}"
}
