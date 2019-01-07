######
# VPC
######

resource "aws_vpc" "this" {

  cidr_block                       = "${var.cidr}"
  instance_tenancy                 = "${var.instance_tenancy}"
  enable_dns_hostnames             = "${var.enable_dns_hostnames}"
  enable_dns_support               = "${var.enable_dns_support}"

  tags = "${merge(map("Name", format("%s", var.name)), var.vpc_tags, var.tags, local.environment_tags)}"
}

################
# Public subnet
################

resource "aws_subnet" "public" {
  count = "${length(var.public_subnets) > 0 && (!var.one_nat_gateway_per_az || length(var.public_subnets) >= length(var.azs)) ? length(var.public_subnets) : 0}"

  vpc_id                  = "${local.vpc_id}"
  cidr_block              = "${var.public_subnets[count.index]}"
  availability_zone       = "${element(var.azs, count.index)}"
  map_public_ip_on_launch = "${var.map_public_ip_on_launch}"

  tags = "${merge(map("Name", format("%s-public-%s", var.name, element(var.azs, count.index))), var.public_subnet_tags, var.tags, local.environment_tags)}"
}

#################
# Private subnet
#################

resource "aws_subnet" "private" {
  count = "${length(var.private_subnets) > 0 ? length(var.private_subnets) : 0}"

  vpc_id            = "${local.vpc_id}"
  cidr_block        = "${var.private_subnets[count.index]}"
  availability_zone = "${element(var.azs, count.index)}"

  tags = "${merge(map("Name", format("%s-private-%s", var.name, element(var.azs, count.index))), var.private_subnet_tags, var.tags, local.environment_tags)}"
}

##################
# Internet Gateway
###################

resource "aws_internet_gateway" "this" {
  
  count = "${length(var.public_subnets) > 0 ? 1 : 0}"
  
  vpc_id = "${local.vpc_id}"

  tags = "${merge(map("Name", format("%s", var.name)), var.igw_tags, var.tags, local.environment_tags)}"
}

################
# Publiс routes
################

resource "aws_route_table" "public" {

  count = "${length(var.public_subnets) > 0 ? 1 : 0}"

  vpc_id = "${local.vpc_id}"

  tags = "${merge(map("Name", format("%s-public", var.name)), var.public_route_table_tags, var.tags, local.environment_tags)}"
}

resource "aws_route" "public_internet_gateway" {

  count = "${length(var.public_subnets) > 0 ? 1 : 0}"

  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.this.id}"

  timeouts {
    create = "5m"
  }
}

#################
# Private routes
#################

resource "aws_route_table" "private" {
  count = "${local.max_subnet_length > 0 ? local.nat_gateway_count : 0}"

  vpc_id = "${local.vpc_id}"

  tags = "${merge(map("Name", (var.single_nat_gateway ? "${var.name}-private" : format("%s-private-%s", var.name, element(var.azs, count.index)))), var.private_route_table_tags, var.tags, local.environment_tags)}"

  lifecycle {
    # When attaching VPN gateways it is common to define aws_vpn_gateway_route_propagation
    # resources that manipulate the attributes of the routing table (typically for the private subnets)
    ignore_changes = ["propagating_vgws"]
  }
}

##############
# NAT Gateway
##############

locals {
  nat_gateway_ips = "${split(",", (var.reuse_nat_ips ? join(",", var.external_nat_ip_ids) : join(",", aws_eip.nat.*.id)))}"
}

resource "aws_eip" "nat" {

  count = "${(var.enable_nat_gateway && !var.reuse_nat_ips) ? local.nat_gateway_count : 0}"
  
  vpc = true

  tags = "${merge(map("Name", format("%s-%s", var.name, element(var.azs, (var.single_nat_gateway ? 0 : count.index)))), var.nat_eip_tags, var.tags, local.environment_tags)}"
}

resource "aws_nat_gateway" "this" {
  
  count = "${var.enable_nat_gateway ? local.nat_gateway_count : 0}"

  allocation_id = "${element(local.nat_gateway_ips, (var.single_nat_gateway ? 0 : count.index))}"
  subnet_id     = "${element(aws_subnet.public.*.id, (var.single_nat_gateway ? 0 : count.index))}"

  tags = "${merge(map("Name", format("%s-%s", var.name, element(var.azs, (var.single_nat_gateway ? 0 : count.index)))), var.nat_gateway_tags, var.tags, local.environment_tags)}"

  depends_on = ["aws_internet_gateway.this"]
}

resource "aws_route" "private_nat_gateway" {

  count = "${var.enable_nat_gateway ? local.nat_gateway_count : 0}"

  route_table_id         = "${element(aws_route_table.private.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${element(aws_nat_gateway.this.*.id, count.index)}"

  timeouts {
    create = "5m"
  }
}

##########################
# Route table association
##########################

resource "aws_route_table_association" "private" {
  count = "${length(var.private_subnets) > 0 ? length(var.private_subnets) : 0}"

  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, (var.single_nat_gateway ? 0 : count.index))}"
}

resource "aws_route_table_association" "public" {
  count = "${length(var.public_subnets) > 0 ? length(var.public_subnets) : 0}"

  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}


