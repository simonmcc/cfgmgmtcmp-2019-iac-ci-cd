provider "aws" {}

variable "vpc_main_cidr" {
  type = "string"
}

variable "vpc_dmz_cidr" {
  type = "string"
}

variable "app_ami" {
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

data "aws_ami" "centos" {
  owners      = ["self"]
  most_recent = true

  filter {
    name   = "name"
    values = ["app *"]
  }

  filter {
    name   = "tag:SHA"
    values = ["${var.app_ami}"]
  }
}

resource "aws_instance" "web" {
  ami           = "${data.aws_ami.centos.id}"
  instance_type = "t2.micro"

  subnet_id = "${

  tags = {
    Name = "HelloWorld"
    Source_AMI_SHA = ["${var.app_ami}"]
  }
}


