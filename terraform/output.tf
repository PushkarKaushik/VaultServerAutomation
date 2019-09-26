output "instance_ips-1"  {
  value = ["${aws_instance.my-test-instance-4.*.private_ip}"]
}

output "instance_ips-2"  {
  value = ["${aws_instance.my-test-instance-5.*.private_ip}"]
}

output "instance_ips-3" {
  value = ["${aws_instance.my-test-instance-6.*.private_ip}"]
}

output "instance_ips-4" {
  value = ["${aws_instance.my-test-instance-1.*.public_ip}"]
}

#output "s3-bucket-name" {
#    value = "${var.aws_bucket_name}"
#}

#output "s3-user-access-key" {
#    value = "${aws_iam_access_key.uploads_user.id}"
#}

#output "s3-user-secret-key" {
#    value = "${aws_iam_access_key.uploads_user.secret}"
#}

