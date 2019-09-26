provider "aws" {
    region = "${var.aws_region}"
}


resource "aws_ami_from_instance" "example" {
  name               = "terraform-example"
  source_instance_id = "i-0bfac595a80516b57"
}


module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
#  version = "~> 3.0"

  name = "service"

  # Launch configuration
  lc_name = "example-lc"

  image_id        = "${aws_ami_from_instance.example.id}"
  instance_type   = "t2.micro"
  security_groups = ["sg-0e2f4798cc354aabb"]
  associate_public_ip_address = "false"

  ebs_block_device = [
    {
      device_name           = "/dev/xvdz"
      volume_type           = "gp2"
      volume_size           = "50"
      delete_on_termination = true
    },
  ]

  root_block_device = [
    {
      volume_size = "50"
      volume_type = "gp2"
    },
  ]

  # Auto scaling group
  asg_name                  = "example-asg"
#  vpc_zone_identifier       = ["subnet-1235678", "subnet-87654321"]
  vpc_zone_identifier       = ["subnet-08b08b696533d52b1", "subnet-010d867ff5b83b992", "subnet-0a24b49ab512fe45c"]
  health_check_type         = "EC2"
  min_size                  = 3
  max_size                  = 5
  desired_capacity          = 3
  wait_for_capacity_timeout = 0

  tags = [
    {
      key                 = "Environment"
      value               = "dev"
      propagate_at_launch = true
    },
    {
      key                 = "Project"
      value               = "megasecret"
      propagate_at_launch = true
    },
  ]

  tags_as_map = {
    extra_tag1 = "extra_value1"
    extra_tag2 = "extra_value2"
  }
}
