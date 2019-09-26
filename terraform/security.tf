#security group
resource "aws_security_group" "alb_sg" {
 description = "controls access to the application ALB"
 vpc_id      = "${aws_vpc.vpc-tf.id}"
  name       = "ALB"

ingress {
   protocol    = "TCP"
   from_port   = 80
   to_port     = 80
   cidr_blocks = ["0.0.0.0/0"]
 }

 egress {
   from_port = 0
   to_port   = 0
   protocol  = "-1"
   cidr_blocks = [
     "0.0.0.0/0",
   ]
 }
}
resource "aws_security_group" "instance_private_sg" {
 description = "controls direct access to application instances"
 vpc_id      = "${aws_vpc.vpc-tf.id}"
 name        = "application-instances-private-sg"
ingress {
   protocol    = "TCP"
   from_port   = 22
   to_port     = 22
   cidr_blocks = ["10.0.0.0/16"]
 }

ingress {
   protocol    = "TCP"
   from_port   = 8200
   to_port     = 8200
   cidr_blocks = ["0.0.0.0/0"]
 }


egress {
   from_port   = 0
   to_port     = 0
   protocol    = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }
}

resource "aws_security_group" "instance_public_sg-1" {
 description = "controls direct access to application instances"
 vpc_id      = "${aws_vpc.vpc-tf.id}"
 name        = "application-instances-private-sg-1"
ingress {
   protocol    = "TCP"
   from_port   = 22
   to_port     = 22
   cidr_blocks = ["${var.my_ip}/32"]
 }

 egress {
   from_port   = 0
   to_port     = 0
   protocol    = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }
}

resource "aws_security_group" "instance_prometheus" {
 description = "controls direct access to application instances"
 vpc_id      = "${aws_vpc.vpc-tf.id}"
 name        = "application-instances-prometheus"
ingress {
   protocol    = "TCP"
   from_port   = 22
   to_port     = 22
   cidr_blocks = ["${var.my_ip}/32"]
 }

ingress {
   protocol    = "TCP"
   from_port   = 80
   to_port     = 80
   cidr_blocks = ["0.0.0.0/0"]
 }

 egress {
   from_port   = 0
   to_port     = 0
   protocol    = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }
}

