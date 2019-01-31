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
    gateway_id = "${aws_internet_gateway.dmz.id}"
  }

  tags = {
    Name = "dmz default table"
  }
}

resource "aws_route_table_association" "dmz" {
  subnet_id      = "${aws_subnet.dmz.id}"
  route_table_id = "${aws_route_table.dmz.id}"
}

resource "aws_security_group" "web_dmz" {
  name        = "Web DMZ"
  description = "Allow ssh, http, https inbound traffic"
  vpc_id      = "${aws_vpc.dmz.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # allow everything out
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
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

  subnet_id                   = "${aws_subnet.dmz.id}"
  associate_public_ip_address = "true"
  vpc_security_group_ids      = ["${aws_security_group.web_dmz.id}"]

  tags = {
    Name           = "HelloWorld"
    Source_AMI_SHA = "${var.app_ami_sha}"
  }
}
