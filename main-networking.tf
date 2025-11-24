resource "random_integer" "randint" {
  min = 1
  max = 10
}

resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr

  enable_dns_hostnames = true
  enable_dns_support   = true

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.name_prefix}-vpc-${random_integer.randint.result}"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "random_shuffle" "az_list" {
  input = data.aws_availability_zones.available.names

  result_count = 10

}

resource "aws_subnet" "my_public_subnets" {
  count = var.public_subnet_count

  vpc_id = aws_vpc.my_vpc.id

  cidr_block              = local.public_cidr_block[count.index]
  map_public_ip_on_launch = true

  availability_zone = random_shuffle.az_list.result[count.index]

  tags = {
    Name = "${var.name_prefix}-public-subnet-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "${var.name_prefix}-igw"
  }
}

resource "aws_route_table" "my_public_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "${var.name_prefix}-public-route-table"
  }
}

resource "aws_route" "my_public_route" {
  route_table_id = aws_route_table.my_public_route_table.id

  gateway_id             = aws_internet_gateway.my_igw.id
  destination_cidr_block = "0.0.0.0/0"

}

resource "aws_route_table_association" "my_public_route_table_association" {
  count = var.public_subnet_count

  route_table_id = aws_route_table.my_public_route_table.id
  subnet_id      = aws_subnet.my_public_subnets[count.index].id
}

resource "aws_security_group" "my_public_security_group" {
  for_each = local.security_groups

  vpc_id = aws_vpc.my_vpc.id

  name        = each.value.name
  description = each.value.description
  tags        = each.value.tags

  dynamic "ingress" {
    for_each = each.value.ingress

    content {
      from_port   = ingress.value.from
      to_port     = ingress.value.to
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "my_db_subnet_group" {
  name = "${var.name_prefix}-db-subnet-group"

  subnet_ids = aws_subnet.my_public_subnets[*].id

  tags = {
    Name = "${var.name_prefix}-db-subnet-group"
  }
}

