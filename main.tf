#
# Module: aws_redshift_with_S3_bucket
#

# This template creates the following resources
# - An Redshift cluster
# - An S3 Bucket
# - A Redshift subnet group
# - You should want your Redshift cluster in a VPC

resource "aws_redshift_cluster" "main_redshift_cluster" {
  cluster_identifier = "${var.cluster_identifier}"
  cluster_version    = "${var.cluster_version}"
  node_type          = "${var.cluster_node_type}"
  number_of_nodes    = "${var.cluster_number_of_nodes}"
  database_name      = "${var.cluster_database_name}"
  master_username    = "${var.cluster_master_username}"
  master_password    = "${var.cluster_master_password}"

  port = "${var.cluster_port}"

  # Because we're assuming a VPC, we use this option, but only one SG id
  vpc_security_group_ids = ["${aws_security_group.main_redshift_access.id}"]

  # We're creating a subnet group in the module and passing in the name
  cluster_subnet_group_name    = "${aws_redshift_subnet_group.main_redshift_subnet_group.name}"
  cluster_parameter_group_name = "${aws_redshift_parameter_group.main_redshift_cluster.id}"

  publicly_accessible = "${var.publicly_accessible}"

  # Snapshots and backups
  skip_final_snapshot                 = "${var.skip_final_snapshot}"
  automated_snapshot_retention_period = "${var.automated_snapshot_retention_period }"
  preferred_maintenance_window        = "${var.preferred_maintenance_window}"

  # IAM Roles
  iam_roles = ["${var.cluster_iam_roles}"]

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_redshift_parameter_group" "main_redshift_cluster" {
  name   = "${var.cluster_identifier}-${replace(var.cluster_parameter_group, ".", "-")}-custom-params"
  family = "${var.cluster_parameter_group}"

  parameter {
    name  = "wlm_json_configuration"
    value = "${var.wlm_json_configuration}"
  }
}

resource "aws_redshift_subnet_group" "main_redshift_subnet_group" {
  name        = "${var.cluster_identifier}-redshift-subnetgrp"
  description = "Redshift subnet group of ${var.cluster_identifier}"
  subnet_ids  = ["${var.subnets}"]
}

# Security groups
resource "aws_security_group" "main_redshift_access" {
  name        = "${var.cluster_identifier}-redshift-access"
  description = "Allow access to the cluster: ${var.cluster_identifier}"
  vpc_id      = "${var.redshift_vpc_id}"

  tags {
    Name = "${var.cluster_identifier}-redshift-access"
  }
}

# Keep rules separated to not recreate the cluster when deleting/adding rules
resource "aws_security_group_rule" "allow_port_inbound" {
  type = "ingress"

  from_port   = "${var.cluster_port}"
  to_port     = "${var.cluster_port}"
  protocol    = "tcp"
  cidr_blocks = ["${var.private_cidr}"]

  security_group_id = "${aws_security_group.main_redshift_access.id}"
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type = "egress"

  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.main_redshift_access.id}"
}



/**
 * A Terraform module that creates a tagged S3 bucket and an IAM user/key with access to the bucket
 */


# we need a service account user
resource "aws_iam_user" "user" {
  name = "srv_${var.bucket_name}"
}

# generate keys for service account user
resource "aws_iam_access_key" "user_keys" {
  user = "${aws_iam_user.user.name}"
}

# create an s3 bucket
resource "aws_s3_bucket" "bucket" {
  bucket        = "${var.bucket_name}"
  force_destroy = "true"

  versioning {
    enabled = "${var.versioning}"
  }

  tags {
    team          = "${var.tag_team}"
    application   = "${var.tag_application}"
    environment   = "${var.tag_environment}"
    contact-email = "${var.tag_contact-email}"
    customer      = "${var.tag_customer}"
  }
}

# grant user access to the bucket
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = "${aws_s3_bucket.bucket.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_user.user.arn}"
      },
      "Action": [ "s3:*" ],
      "Resource": [
        "${aws_s3_bucket.bucket.arn}",
        "${aws_s3_bucket.bucket.arn}/*"
      ]
    }
  ]
}
