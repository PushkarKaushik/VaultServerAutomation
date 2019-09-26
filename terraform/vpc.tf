#VPC creation

resource "aws_vpc" "vpc-tf" {
 cidr_block           = "10.0.0.0/16"
 enable_dns_support   = "true"
 enable_dns_hostnames = "true"
 enable_classiclink   = "false"
 tags = {
   Name = "vpc-terraform"
 }
}
#Public subnet in different zone "us-east-1"
resource "aws_subnet" "vpc-public-1" {
 vpc_id                  = "${aws_vpc.vpc-tf.id}"
 cidr_block              = "10.0.1.0/24"
 map_public_ip_on_launch = "true"
 availability_zone       = "us-east-1a"
 tags = {
   Name = "vpc-public-1"
 }
}

resource "aws_subnet" "vpc-public-2" {
 vpc_id                  = "${aws_vpc.vpc-tf.id}"
 cidr_block              = "10.0.2.0/24"
 map_public_ip_on_launch = "true"
 availability_zone       = "us-east-1b"
 tags = {
   Name = "vpc-public-2"
 }
}

resource "aws_subnet" "vpc-public-3" {
 vpc_id                  = "${aws_vpc.vpc-tf.id}"
 cidr_block              = "10.0.3.0/24"
 map_public_ip_on_launch = "true"
 availability_zone       = "us-east-1c"
 tags = {
   Name = "vpc-public-3"
 }
}


resource "aws_subnet" "vpc-private-2" {
 vpc_id                  = "${aws_vpc.vpc-tf.id}"
 cidr_block              = "10.0.4.0/24"
 map_public_ip_on_launch = "true"
 availability_zone       = "us-east-1a"
 tags = {
   Name = "vpc-private-2"
 }
}

resource "aws_subnet" "vpc-private-3" {
 vpc_id                  = "${aws_vpc.vpc-tf.id}"
 cidr_block              = "10.0.5.0/24"
 map_public_ip_on_launch = "true"
 availability_zone       = "us-east-1b"
 tags = {
   Name = "vpc-private-3"
 }
}

resource "aws_subnet" "vpc-private-4" {
 vpc_id                  = "${aws_vpc.vpc-tf.id}"
 cidr_block              = "10.0.6.0/24"
 map_public_ip_on_launch = "true"
 availability_zone       = "us-east-1c"
 tags = {
   Name = "vpc-private-4"
 }
}


resource "aws_internet_gateway" "igw" {
vpc_id                  = "${aws_vpc.vpc-tf.id}"
tags = {
 name = "igw"
}
}

resource "aws_route_table" "public" {
vpc_id  = "${aws_vpc.vpc-tf.id}"
tags = {
 name = "public"
}
}

resource "aws_route" "public_internet_gateway" {
 route_table_id  = "${aws_route_table.public.id}"
 destination_cidr_block = "0.0.0.0/0"
 gateway_id = "${aws_internet_gateway.igw.id}"
}

resource "aws_route_table_association" "public-1" {
subnet_id = "${aws_subnet.vpc-public-1.id}"
route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "public-2" {
subnet_id = "${aws_subnet.vpc-public-2.id}"
route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "public-3" {
subnet_id = "${aws_subnet.vpc-public-3.id}"
route_table_id = "${aws_route_table.public.id}"
}


resource "aws_eip" "nat_eip" {
vpc         = true
}

resource "aws_nat_gateway" "nat" {
 allocation_id = "${aws_eip.nat_eip.id}"
 subnet_id     = "${aws_subnet.vpc-public-1.id}"
 depends_on = ["aws_internet_gateway.igw"]
tags = {
 name = "gw NAT-1"
}
}

resource "aws_route_table" "private" {
vpc_id     = "${aws_vpc.vpc-tf.id}"
tags = {
name = "private"
}
}

resource "aws_route" "private_nat_gateway" {
route_table_id  = "${aws_route_table.private.id}"
destination_cidr_block = "0.0.0.0/0"
nat_gateway_id  = "${aws_nat_gateway.nat.id}"
}

resource "aws_route_table_association" "private-2" {
subnet_id  = "${aws_subnet.vpc-private-2.id}"
route_table_id = "${aws_route_table.private.id}"
}

resource "aws_route_table_association" "private-3" {
subnet_id  = "${aws_subnet.vpc-private-3.id}"
route_table_id = "${aws_route_table.private.id}"
}

resource "aws_route_table_association" "private-4" {
subnet_id  = "${aws_subnet.vpc-private-4.id}"
route_table_id = "${aws_route_table.private.id}"
}

