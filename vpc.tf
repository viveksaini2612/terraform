provider "aws" {
  region = "ap-south-1"
  profile = "terraprofile"
}


resource "aws_vpc" "myvpc1" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = true

  tags = {
    Name = "myvpc1"
  }

}





resource "aws_internet_gateway" "mygate5" {
depends_on = [ aws_vpc.myvpc1 ]
vpc_id = aws_vpc.myvpc1.id
tags = {
Name = "mygate5"
}
}

resource "aws_route" "myroute5" {
depends_on = [ aws_vpc.myvpc1 , aws_internet_gateway.mygate5 ]
route_table_id = aws_vpc.myvpc1.default_route_table_id
destination_cidr_block = "0.0.0.0/0"
gateway_id = aws_internet_gateway.mygate5.id


}


resource "aws_security_group" "mysec5" {
depends_on = [
aws_vpc.myvpc1
]
vpc_id = aws_vpc.myvpc1.id
ingress {
description = "ssh"
protocol = "tcp"
from_port = 22
to_port = 22
cidr_blocks = ["0.0.0.0/0"]
}
ingress {
description = "http"
protocol = "tcp"
from_port = 80
to_port = 80
cidr_blocks = ["0.0.0.0/0"]
}
ingress {
description = "https"
from_port = 443
to_port = 443
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}
egress {
from_port = 0
to_port = 0
protocol = "-1"
cidr_blocks = ["0.0.0.0/0"]
}
tags = {
Name = "mysec5"
}
}



resource "aws_subnet" "Public5" {
vpc_id = "${aws_vpc.myvpc1.id}"
cidr_block = "10.0.0.0/24"


tags = {
Name = "Public5"
}
}

resource "aws_route_table" "Public5" {
    vpc_id = "${aws_vpc.myvpc1.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.mygate5.id}"
    }

tags = {
Name = "Public5"
}
}

resource "aws_route_table_association" "Public5" {
    subnet_id = "${aws_subnet.Public5.id}"
    route_table_id = "${aws_route_table.Public5.id}"
}










resource "aws_subnet" "Private5" {
    vpc_id = "${aws_vpc.myvpc1.id}"
    cidr_block = "10.0.1.0/24"

tags = {
Name = "Private5"
}

}

resource "aws_route_table" "Private5" {
    vpc_id = "${aws_vpc.myvpc1.id}"

    route {
        cidr_block = "0.0.0.0/0"
	gateway_id = "${aws_internet_gateway.mygate5.id}"
    }

tags = {
Name = "Private5"
}
}

resource "aws_route_table_association" "Private5" {
    subnet_id = "${aws_subnet.Private5.id}"
    route_table_id = "${aws_route_table.Private5.id}"
}











resource "aws_instance" "Wordpress" {
    ami = "ami-0447a12f28fddb066"
    instance_type = "t2.micro"
    key_name = "mykey1"
    vpc_security_group_ids = ["${aws_security_group.mysec5.id}"]
    subnet_id = "${aws_subnet.Public5.id}"
    associate_public_ip_address = true


tags = {
Name = "wordpress"
}
}