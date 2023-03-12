resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name        = "smiddie-${var.infra_env}-vpc"
    Project     = "smiddievpc"
    Environment = var.infra_env
    ManagedBy   = "terraform"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name        = "main-${var.infra_env}"
    Project     = "smiddievpc"
    Environment = var.infra_env
    ManagedBy   = "terraform"
  }
}

resource "aws_route_table" "publicrt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.publicrt.id
}
resource "aws_subnet" "public" {
  for_each          = var.public_subnet_numbers
  vpc_id            = aws_vpc.vpc.id
  availability_zone = each.key

  cidr_block = cidrsubnet(aws_vpc.vpc.cidr_block, 4, each.value)

  tags = {
    Name        = "smiddie-${var.infra_env}-public_subnet-${each.value}"
    Project     = "smiddievpc"
    Role        = "public"
    Environment = var.infra_env
    ManagedBy   = "terraform"
    Subnet      = "${each.key}-${each.value}"
  }
}

resource "aws_subnet" "private" {
  for_each = var.private_subnet_numbers

  vpc_id            = aws_vpc.vpc.id
  availability_zone = each.key

  cidr_block = cidrsubnet(aws_vpc.vpc.cidr_block, 4, each.value)

  tags = {
    Name        = "smiddie-${var.infra_env}-private_subnet-${each.value - 3}"
    Project     = "smiddievpc"
    Role        = "private"
    Environment = var.infra_env
    ManagedBy   = "terraform"
    Subnet      = "${each.key}-${each.value}"
  }
}