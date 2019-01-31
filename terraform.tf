provider "aws" {}

variable "vpc_main_cidr" {
  type = "string"
}

variable "vpc_dmz_cidr" {
  type = "string"
}

variable "subnet_dmz_cidr" {
  type = "string"
}

variable "app_ami_sha" {
  type = "string"
}

resource "aws_vpc" "main" {
  cidr_block = "${var.vpc_main_cidr}"
}

output "main_vpc_id" {
  value = "${aws_vpc.main.id}"
}

resource "aws_vpc" "dmz" {
  cidr_block = "${var.vpc_dmz_cidr}"
}

output "dmz_vpc_id" {
  value = "${aws_vpc.dmz.id}"
}

resource "aws_subnet" "dmz" {
  vpc_id     = "${aws_vpc.dmz.id}"
  cidr_block = "${var.subnet_dmz_cidr}"

  tags = {
    Name = "dmz-subnet"
  }
}

resource "aws_internet_gateway" "dmz" {
  vpc_id = "${aws_vpc.dmz.id}"

  tags = {
    Name = "dmz-igw"
  }
}

resource "aws_route_table" "dmz" {
  vpc_id = "${aws_vpc.dmz.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id  = "${aws_internet_gateway.dmz.id}"
  }

  tags = {
    Name = "dmz default table"
  }
}

resource "aws_route_table_association" "dmz" {
  subnet_id      = "${aws_subnet.dmz.id}"
  route_table_id = "${aws_route_table.dmz.id}"
}

data "aws_ami" "centos" {
  owners      = ["self"]
  most_recent = true

  filter {
    name   = "name"
    values = ["app *"]
  }

  filter {
    name   = "tag:SHA"
    values = ["${var.app_ami_sha}"]
  }
}

resource "aws_instance" "web" {
  ami           = "${data.aws_ami.centos.id}"
  instance_type = "t2.micro"

  subnet_id = "${aws_subnet.dmz.id}"
  associate_public_ip_address = "true"

  tags = {
    Name = "HelloWorld"
    Source_AMI_SHA = "${var.app_ami_sha}"
  }
}


