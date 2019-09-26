variable "aws_region" {}

variable "public_tag" {}

variable "aws_bucket_name" {}

variable "my_ip" {}

variable "instanceType" {}
variable "instanceTypePrometheus" {}
variable "prometheusTag" {}

variable "AmiLinux" {
  type = "map"
  default = {
    us-east-1 = "ami-07d0cf3af28718ef8" # Virginia
  }
  description = "have only added one region"
}

variable "instance_count" {
  default = "1"
}

variable "aws_region_main" {
  default = "eu-west-1"
}
variable "aws_region_replica" {
  default = "eu-central-1"
}


