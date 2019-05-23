### VPC ### 
resource "aws_vpc" "vpc" {
  cidr_block = "${var.vpc-cidr}"
  enable_dns_hostnames = true

  tags {
    Name = "${var.resource-prefix}-vpc"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = {
    Name = "${var.resource-prefix}-igw"
  }
}

# Create NAT
resource "aws_eip" "nat-eip" {
  vpc = true

  tags = {
    Name = "${var.resource-prefix}-nat-eip"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.nat-eip.id}"
  subnet_id = "${aws_subnet.public-subnet-1.id}"
  depends_on = ["aws_internet_gateway.igw"]

  tags = {
    Name = "${var.resource-prefix}-nat"
  }
}

# Create public and private route tables
resource "aws_route_table" "public-route-table" {
  vpc_id = "${aws_vpc.vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags {
    Name = "${var.resource-prefix}-public-route-table"
  }
}

resource "aws_route_table" "private-route-table" {
  vpc_id = "${aws_vpc.vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat.id}"
  }

  tags {
    Name = "${var.resource-prefix}-private-route-table"
  }
}

# Create and associate public subnets with a route table
resource "aws_subnet" "public-subnet-1" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "${cidrsubnet(var.vpc-cidr, 8, 1)}"
  availability_zone = "${element(split(",",var.aws-availability-zones), count.index)}"
  map_public_ip_on_launch = true

  tags {
    Name = "${var.resource-prefix}-public-subnet-1"
  }
}

resource "aws_route_table_association" "public-table-assoc-1" {
  subnet_id = "${aws_subnet.public-subnet-1.id}"
  route_table_id = "${aws_route_table.public-route-table.id}"
}

resource "aws_subnet" "public-subnet-2" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "${cidrsubnet(var.vpc-cidr, 8, 3)}"
  availability_zone = "${element(split(",",var.aws-availability-zones), count.index + 1)}"
  map_public_ip_on_launch = true

  tags {
    Name = "${var.resource-prefix}-public-subnet-2"
  }
}

resource "aws_route_table_association" "public-table-assoc-2" {
  subnet_id = "${aws_subnet.public-subnet-2.id}"
  route_table_id = "${aws_route_table.public-route-table.id}"
}

# Create and associate private subnets with a route table
resource "aws_subnet" "private-subnet-1" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "${cidrsubnet(var.vpc-cidr, 8, 2)}"
  availability_zone = "${element(split(",",var.aws-availability-zones), count.index)}"
  map_public_ip_on_launch = false

  tags {
    Name = "${var.resource-prefix}-private-subnet-1"
  }
}

resource "aws_route_table_association" "private-table-assoc-1" {
  subnet_id = "${aws_subnet.private-subnet-1.id}"
  route_table_id = "${aws_route_table.private-route-table.id}"
}

resource "aws_subnet" "private-subnet-2" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "${cidrsubnet(var.vpc-cidr, 8, 4)}"
  availability_zone = "${element(split(",",var.aws-availability-zones), count.index + 1)}"
  map_public_ip_on_launch = false

  tags {
    Name = "${var.resource-prefix}-private-subnet-2"
  }
}

resource "aws_route_table_association" "private-table-assoc-2" {
  subnet_id = "${aws_subnet.private-subnet-2.id}"
  route_table_id = "${aws_route_table.private-route-table.id}"
}
