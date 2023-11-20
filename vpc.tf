locals {
  public_subnets = {
    "${var.aws-config.region_primary}a" = "10.20.30.0/27"
    "${var.aws-config.region_primary}b" = "10.20.30.32/27"
  }
  private_subnets = {
    "${var.aws-config.region_primary}a" = "10.20.30.64/27"
    "${var.aws-config.region_primary}b" = "10.20.30.96/27"
  }
}
resource "aws_vpc" "claranet" {
  cidr_block = var.vpc-config.cidr

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc-config.name
  }
}

resource "aws_subnet" "public_subnets" {
  count      = length(local.public_subnets)
  cidr_block = element(values(local.public_subnets), count.index)
  vpc_id     = aws_vpc.claranet.id

  map_public_ip_on_launch = true
  availability_zone       = element(keys(local.public_subnets), count.index)

  tags = {
    Name = "${var.vpc-config.public_subnet_name}-${element(["a", "b"], count.index)}"
  }
}

resource "aws_subnet" "private_subnets" {
  count      = length(local.private_subnets)
  cidr_block = element(values(local.private_subnets), count.index)
  vpc_id     = aws_vpc.claranet.id

  map_public_ip_on_launch = true
  availability_zone       = element(keys(local.private_subnets), count.index)

  tags = {
    Name = "${var.vpc-config.private_subnet_name}-${element(["a", "b"], count.index)}"
  }
}

#### Things Required for Public Subnet

resource "aws_internet_gateway" "claranet" {
  vpc_id = aws_vpc.claranet.id

  tags = {
    Name = var.vpc-config.internet_gateway_name
  }
}
resource "aws_default_route_table" "public" {
  default_route_table_id = aws_vpc.claranet.main_route_table_id

  tags = {
    Name = var.vpc-config.internet_gateway_routetable_name
  }
}

resource "aws_route" "public_internet_gateway" {
  count                  = length(local.public_subnets)
  route_table_id         = aws_default_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.claranet.id

  timeouts {
    create = "5m"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(local.public_subnets)
  subnet_id      = element(aws_subnet.public_subnets.*.id, count.index)
  route_table_id = aws_default_route_table.public.id
}

#### Things Required for Private Subnet

resource "aws_eip" "nat" {
  count  = length(local.public_subnets)
  domain = "vpc"

  tags = {
    Name = var.vpc-config.nat_gateway_eip_name
  }
}

resource "aws_route_table" "private" {
  count          = length(local.private_subnets)
  vpc_id = aws_vpc.claranet.id

  tags = {
    Name = "${var.vpc-config.nat_gateway_routetable_name}-${element(["a", "b"], count.index)}"
  }
}

resource "aws_nat_gateway" "claranet" {
  count          = length(local.public_subnets)
  allocation_id = element(aws_eip.nat.*.id, count.index)
  subnet_id     = element(aws_subnet.public_subnets.*.id, count.index)

  tags = {
    Name = "${var.vpc-config.nat_gateway_name}-${element(["a", "b"], count.index)}"
  }
}

resource "aws_route_table_association" "private" {
  count          = length(local.private_subnets)
  subnet_id      = element(aws_subnet.private_subnets.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}

resource "aws_route" "private_nat_gateway" {
  count  = length(local.public_subnets)
  route_table_id         = element(aws_route_table.private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.claranet.*.id, count.index)

  timeouts {
    create = "5m"
  }
}