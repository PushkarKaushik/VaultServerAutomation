resource "aws_lb_target_group" "vault" {
 name       = "vault"
 port       = 8200
 protocol   = "HTTP"
 vpc_id     = "${aws_vpc.vpc-tf.id}"
 depends_on = ["aws_lb.eu_alb"]
 stickiness {
   type            = "lb_cookie"
   cookie_duration = 86400
 }
 health_check {
   path                = "/ui/vault/init"
   healthy_threshold   = 2
   unhealthy_threshold = 10
   timeout             = 60
   interval            = 300
 }
}


resource "aws_lb" "eu_alb" {
 name     = "eu-alb"
 load_balancer_type = "application"
 subnets  = ["${aws_subnet.vpc-public-1.id}", "${aws_subnet.vpc-public-2.id}", "${aws_subnet.vpc-public-3.id}"]
 security_groups = ["${aws_security_group.alb_sg.id}"]
 enable_http2    = "true"
}

resource "aws_lb_listener" "front_end" {
 load_balancer_arn = "${aws_lb.eu_alb.id}"
 port              = "80"
 protocol          = "HTTP"
 default_action {
   target_group_arn = "${aws_lb_target_group.vault.id}"
   type             = "forward"
  }
 }

resource "aws_lb_target_group_attachment" "private-1" {
  target_group_arn = "${aws_lb_target_group.vault.arn}"
  target_id        = "${aws_instance.my-test-instance-4.id}"
  port             = 8200
}

resource "aws_lb_target_group_attachment" "private-2" {
  target_group_arn = "${aws_lb_target_group.vault.arn}"
  target_id        = "${aws_instance.my-test-instance-5.id}"
  port             = 8200
}

resource "aws_lb_target_group_attachment" "private-3" {
  target_group_arn = "${aws_lb_target_group.vault.arn}"
  target_id        = "${aws_instance.my-test-instance-6.id}"
  port             = 8200
}


#  cross_zone_load_balancing   = true
#  idle_timeout                = 400
#  connection_draining         = true
#  connection_draining_timeout = 400


#resource "aws_elb_attachment" "private-1" {
#  elb      = "${aws_lb.eu_alb.id}"
#  instance = "${aws_instance.my-test-instance-4.id}"
#}

#resource "aws_elb_attachment" "private-2" {
#  elb      = "${aws_lb.eu_alb.id}"
#  instance = "${aws_instance.my-test-instance-5.id}"
#}

#resource "aws_elb_attachment" "private-3" {
#  elb      = "${aws_lb.eu_alb.id}"
#  instance = "${aws_instance.my-test-instance-6.id}"
#}
