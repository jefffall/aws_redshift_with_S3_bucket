#
# Module: aws_redshift_with_S3_bucket
#

# Output the ID of the Redshift cluster
output "redshift_cluster_id" {
  value = "${aws_redshift_with_S3_bucket.main_redshift_cluster.id}"
}

# Output address (hostname) of the Redshift cluster
output "redshift_cluster_address" {
  value = "${replace(aws_redshift_with_S3_bucket.main_redshift_cluster.endpoint, format(":%s", aws_redshift_with_S3_bucket.main_redshift_cluster.port), "")}"
}

# Output endpoint (hostname:port) of the Redshift cluster
output "redshift_cluster_endpoint" {
  value = "${aws_redshift_with_S3_bucket.main_redshift_cluster.endpoint}"
}

# Output host zone id
output "redshift_cluster_hosted_zone_id" {
  value = "${aws_redshift_with_S3_bucket.main_redshift_cluster.hosted_zone_id}"
}

# Output the ID of the Subnet Group
output "subnet_group_id" {
  value = "${aws_redshift_subnet_group.main_redshift_subnet_group.id}"
}

# Output DB security group ID
output "security_group_id" {
  value = "${aws_security_group.main_redshift_access.id}"
}

#the arn of the user that was created
output "user_arn" {
  value = "${aws_redshift_with_S3_bucket.user.arn}"
}

#the name of the service account user that was created
output "user_name" {
  value = "${aws_redshift_with_S3_bucket.user.name}" } #the arn of the bucket that was created output "bucket_arn" {
  value = "${aws_redshift_with_S3_bucket.bucket.arn}"
}

#the name of the bucket
output "bucket_name" {
  value = "${aws_redshift_with_S3_bucket.bucket.id}"
}

#the access key
output "iam_access_key_id" {
  value = "${aws_iam_access_key.user_keys.id}"
}

#the access key secret
output "iam_access_key_secret" {
  value = "${aws_iam_access_key.user_keys.secret}"
}

