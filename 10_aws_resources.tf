## VPC ##
resource "aws_vpc" "vpc" {
  cidr_block = "${lookup(var.network_scope, terraform.workspace)}"
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags {
    Name = "${terraform.workspace}"
  }
}


## Subnets ##
resource "aws_subnet" "subnet_a_public" {
  vpc_id = "${aws_vpc.vpc.id}"
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
  cidr_block = "${lookup(var.subnet_scope[terraform.workspace], "a_public")}"
  map_public_ip_on_launch = true
  tags {
    Name = "${terraform.workspace}"
  }
}

resource "aws_subnet" "subnet_b_public" {
  vpc_id = "${aws_vpc.vpc.id}"
  availability_zone = "${data.aws_availability_zones.available.names[1]}"
  cidr_block = "${lookup(var.subnet_scope[terraform.workspace], "b_public")}"
  map_public_ip_on_launch = true
  tags {
    Name = "${terraform.workspace}"
  }
}

resource "aws_subnet" "subnet_a_private" {
  vpc_id = "${aws_vpc.vpc.id}"
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
  cidr_block = "${lookup(var.subnet_scope[terraform.workspace], "a_private")}"
  tags {
    Name = "${terraform.workspace}"
  }
}

resource "aws_subnet" "subnet_b_private" {
  vpc_id = "${aws_vpc.vpc.id}"
  availability_zone = "${data.aws_availability_zones.available.names[1]}"
  cidr_block = "${lookup(var.subnet_scope[terraform.workspace] ,"b_private")}"
  tags {
    Name = "${terraform.workspace}"
  }
}

## Internet Gateways ##
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags {
    Name = "${terraform.workspace}"
  }
}

resource "aws_eip" "nat_eip_a" {
  vpc = true
  tags {
    Name = "${terraform.workspace}_nat_eip_a"
  }
}

resource "aws_eip" "nat_eip_b" {
  vpc = true
  tags {
    Name = "${terraform.workspace}_nat_eip_b"
  }
}

resource "aws_nat_gateway" "nat_gw_a" {
  allocation_id = "${aws_eip.nat_eip_a.id}"
  subnet_id = "${aws_subnet.subnet_a_public.id}"
  tags {
    Name = "{terraform.workspace}"
  }
}

resource "aws_nat_gateway" "nat_gw_b" {
  allocation_id = "${aws_eip.nat_eip_b.id}"
  subnet_id = "${aws_subnet.subnet_b_public.id}"
  tags {
    Name = "{terraform.workspace}"
  }
}

## Routing  ##
resource "aws_route_table" "rt_subnet_a_private" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags = {
    Name = "${terraform.workspace}"
  }
}

resource "aws_route_table" "rt_subnet_b_private" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags = {
    Name = "${terraform.workspace}"
  }
}

resource "aws_route_table_association" "rt_assoc_a_private" {
  subnet_id = "${aws_subnet.subnet_a_private.id}"
  route_table_id = "${aws_route_table.rt_subnet_a_private.id}"
}

resource "aws_route_table_association" "rt_assoc_b_private" {
  subnet_id = "${aws_subnet.subnet_b_private.id}"
  route_table_id = "${aws_route_table.rt_subnet_b_private.id}"
}

resource "aws_route" "default" {
  route_table_id = "${aws_vpc.vpc.default_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.igw.id}"
}

resource "aws_route" "default_a_private" {
  route_table_id = "${aws_route_table.rt_subnet_a_private.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = "${aws_nat_gateway.nat_gw_a.id}"
}

resource "aws_route" "default_b_private" {
  route_table_id = "${aws_route_table.rt_subnet_b_private.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = "${aws_nat_gateway.nat_gw_b.id}"
}
