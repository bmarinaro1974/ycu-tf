resource "aws_subnet" "pub" {
  vpc_id = "${aws_vpc.ycu.id}"
  count = 3
  cidr_block = "${cidrsubnet(module.pub_cidr_block.value,2 ,count.index )}"
  availability_zone = "${element(split(",",lookup(var.zones,var.region ) ),count.index )}"
  map_public_ip_on_launch = true
}

resource "aws_route_table" "pub" {
  vpc_id = "${aws_vpc.ycu.id}"

  route{
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.ycu.id}"
  }
}

resource "aws_route_table_association" "pub" {
  count = 3
  subnet_id = "${element(aws_subnet.pub.*.id,count.index)}"
  route_table_id = "${aws_route_table.pub.id}"
}

