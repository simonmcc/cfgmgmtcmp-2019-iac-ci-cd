provider "aws" {
  skip_credentials_validation = true
}

variable "vpc_packer_cidr" {
  type = "string"
}

variable "subnet_packer_cidr" {
  type = "string"
}

resource "aws_vpc" "packer" {
  cidr_block = "${var.vpc_packer_cidr}"

  tags = {
    Name = "packer-vpc"
  }
}

resource "aws_subnet" "packer" {
  vpc_id     = "${aws_vpc.packer.id}"
  cidr_block = "${var.subnet_packer_cidr}"

  tags = {
    Name = "packer-subnet"
  }
}

resource "aws_internet_gateway" "packer" {
  vpc_id = "${aws_vpc.packer.id}"

  tags = {
    Name = "packer-igw"
  }
}

resource "aws_route_table" "packer" {
  vpc_id = "${aws_vpc.packer.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.packer.id}"
  }

  tags = {
    Name = "packer default table"
  }
}

resource "aws_route_table_association" "packer" {
  subnet_id      = "${aws_subnet.packer.id}"
  route_table_id = "${aws_route_table.packer.id}"
}
