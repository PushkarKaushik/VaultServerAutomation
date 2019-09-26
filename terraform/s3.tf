# This configures aws – required in all terraform files
provider "aws" {
   region = "${var.aws_region}"
}

# Defines a user that should be able to write to you test bucket

resource "aws_iam_role" "ec2_s3_access_role" {
  name               = "${var.aws_bucket_name}"
  assume_role_policy = "${file("assumerolepolicy.json")}"
}

resource "aws_iam_policy" "policy" {
  name        = "test-policy"
  description = "A test policy"
  policy      = "${file("policys3bucket.json")}"
}

resource "aws_iam_policy_attachment" "test-attach" {
  name       = "test-attachment"
  roles      = ["${aws_iam_role.ec2_s3_access_role.name}"]
  policy_arn = "${aws_iam_policy.policy.arn}"
}

resource "aws_iam_instance_profile" "test_profile-1" {
  name  = "test_profile-1"
  roles = ["${aws_iam_role.ec2_s3_access_role.name}"]
}

resource "aws_instance" "my-test-instance-1" {
  ami             = "${lookup(var.AmiLinux, var.aws_region)}"
  subnet_id       = "${aws_subnet.vpc-public-1.id}"
  security_groups = ["${aws_security_group.instance_public_sg-1.id}"]
  #count           = "${var.instance_count}"
  instance_type   = "${var.instanceType}"
  key_name   = "nvirginia"
  tags = {
      Name = "${var.public_tag}"
    }
}

resource "aws_instance" "Prometheus" {
  ami             = "${lookup(var.AmiLinux, var.aws_region)}"
  subnet_id       = "${aws_subnet.vpc-public-2.id}"
  security_groups = ["${aws_security_group.instance_prometheus.id}"]
  #count           = "${var.instance_count}"
  instance_type   = "${var.instanceTypePrometheus}"
  key_name   = "nvirginia"
  tags = {
      Name = "${var.prometheusTag}"
    }
}


resource "aws_instance" "my-test-instance-4" {
  ami             = "${lookup(var.AmiLinux, var.aws_region)}"
  subnet_id       = "${aws_subnet.vpc-private-2.id}"
  security_groups = ["${aws_security_group.instance_private_sg.id}"]
  #count           = "${var.instance_count}"
  associate_public_ip_address = "false"
  instance_type   = "${var.instanceType}"
  iam_instance_profile = "${aws_iam_instance_profile.test_profile-1.name}"
  key_name   = "nvirginia"
}

resource "aws_instance" "my-test-instance-5" {
  ami             = "${lookup(var.AmiLinux, var.aws_region)}"
  subnet_id       = "${aws_subnet.vpc-private-3.id}"
  security_groups = ["${aws_security_group.instance_private_sg.id}"]
  #count           = "${var.instance_count}"
  associate_public_ip_address = "false"
  instance_type   = "${var.instanceType}"
  iam_instance_profile = "${aws_iam_instance_profile.test_profile-1.name}"
  key_name   = "nvirginia"
}

resource "aws_instance" "my-test-instance-6" {
  ami             = "${lookup(var.AmiLinux, var.aws_region)}"
  subnet_id       = "${aws_subnet.vpc-private-4.id}"
  security_groups = ["${aws_security_group.instance_private_sg.id}"]
  #count           = "${var.instance_count}"
  associate_public_ip_address = "false"
  instance_type   = "${var.instanceType}"
  iam_instance_profile = "${aws_iam_instance_profile.test_profile-1.name}"
  key_name   = "nvirginia"
}


# Give Different aliases for aws regions
provider "aws" {
  alias  = "west"
  region = "eu-west-1"
}
provider "aws" {
  alias  = "central"
  region = "eu-central-1"
}

# Create replication role
resource "aws_iam_role" "replication" {
  name               = "tf-iam-role-replication-12345"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "replication" {
    name = "tf-iam-role-policy-replication-12345"
    policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetReplicationConfiguration",
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.uploads.arn}"
      ]
    },
    {
      "Action": [
        "s3:GetObjectVersion",
        "s3:GetObjectVersionAcl"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.uploads.arn}/*"
      ]
    },
    {
      "Action": [
        "s3:ReplicateObject",
        "s3:ReplicateDelete"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.replica.arn}/*"
    }
  ]
}
POLICY
}

resource "aws_iam_policy_attachment" "replication" {
    name = "tf-iam-role-attachment-replication-12345"
    roles = ["${aws_iam_role.replication.name}"]
    policy_arn = "${aws_iam_policy.replication.arn}"
}

# This is the replication bucket for uploads
resource "aws_s3_bucket" "replica" {
    provider = "aws.central"
    bucket   = "${var.aws_bucket_name}-replica-1"
    region   = "${var.aws_region_replica}"
    acl      = "private"

    # Enable versioning so that files can be replicated
    versioning {
      enabled = true
    }

    # Remove old versions of images after 15 days
    lifecycle_rule {
        prefix = ""
        enabled = true

        noncurrent_version_expiration {
            days = 15
        }
    }
}

# This is the main s3 bucket for uploads
resource "aws_s3_bucket" "uploads" {
    provider = "aws.west"
    bucket = "${var.aws_bucket_name}"
    acl = "private"
    region = "${var.aws_region_main}"

    # Enable versioning so that files can be replicated
    versioning {
      enabled = true
    }

    # Remove old versions after 15 days, these shouldn't happen that often because
    # humanmade/s3-uploads will rename files which have same name
    lifecycle_rule {
        prefix = ""
        enabled = true

        noncurrent_version_expiration {
            days = 15
        }
    }

    replication_configuration {
        role = "${aws_iam_role.replication.arn}"
        rules {
            id     = "replica"
            prefix = ""
            status = "Enabled"

            destination {
                bucket        = "${aws_s3_bucket.replica.arn}"
                storage_class = "STANDARD"
            }
        }
    }
}

resource "aws_iam_user" "uploads_user" {
    name = "${var.aws_bucket_name}-user"
}

resource "aws_iam_access_key" "uploads_user" {
    user = "${aws_iam_user.uploads_user.name}"
}

resource "aws_iam_user_policy" "wp_uploads_policy" {
    name = "WordPress-S3-Uploads"
    user = "${aws_iam_user.uploads_user.name}"

    # S3 policy from humanmade/s3-uploads for WordPress uploads
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1392016154000",
      "Effect": "Allow",
      "Action": [
        "s3:AbortMultipartUpload",
        "s3:DeleteObject",
        "s3:GetBucketAcl",
        "s3:GetBucketLocation",
        "s3:GetBucketPolicy",
        "s3:GetObject",
        "s3:GetObjectAcl",
        "s3:ListBucket",
        "s3:ListBucketMultipartUploads",
        "s3:ListMultipartUploadParts",
        "s3:PutObject",
        "s3:PutObjectAcl"
      ],
      "Resource": [
        "arn:aws:s3:::${aws_s3_bucket.uploads.bucket}/*"
      ]
    },
    {
      "Sid": "AllowRootAndHomeListingOfBucket",
      "Action": ["s3:ListBucket"],
      "Effect": "Allow",
      "Resource": ["arn:aws:s3:::${aws_s3_bucket.uploads.bucket}"],
      "Condition":{"StringLike":{"s3:prefix":["*"]}}
    }
  ]
}
EOF
}

