resource "aws_subnet" "web" {
  vpc_id = "${aws_vpc.ycu.id}"
  count = 3
  cidr_block = "${cidrsubnet(module.web_cidr_block.value,2 ,count.index )}"
  availability_zone = "${element(split(",",lookup(var.zones,var.region ) ),count.index )}"
  map_public_ip_on_launch = true
}

resource "aws_route_table_association" "web" {
  count = 3
  subnet_id = "${element(aws_subnet.web.*.id,count.index)}"
  route_table_id = "${aws_route_table.ycu.id}"
}

