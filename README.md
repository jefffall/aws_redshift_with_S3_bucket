Thie Module creates  the following resources:

    An S3 bucket with private default acl
    A redshift cluster with IAM role that allows read/write access to the bucket

Input parameters:

    Number of nodes
    Node type/size
    Name of bucket/cluster
    Charge Code tag to be applied to all resources

Outputs:

    Redshift endpoint
    S3 bucket ARN


module "aws_redshift_with_S3_bucket" {
  source  = "github.com/jefffall/aws_redshift_with_S3_bucket"

  # Redshift Cluster Inputs
  cluster_identifier      = "${var.redshift_cluster_identifier}"
  cluster_node_type       = "${var.redshift_cluster_node_type}"
  cluster_number_of_nodes = "${var.redshift_cluster_number_of_nodes}"

  cluster_database_name   = "${var.redshift_cluster_database_name}"
  cluster_master_username = "${var.redshift_cluster_master_username}"
  cluster_master_password = "${var.redshift_cluster_master_password}"

  # Group parameters
  wlm_json_configuration     = "${var.redshift_cluster_wlm_json_configuration}"

  # DB Subnet Group Inputs
  subnets         = ["${var.public_subnets}"]
  redshift_vpc_id = "${var.vpc_id}"
  private_cidr    = "${var.vpc_cidr}"

  # IAM Roles
  cluster_iam_roles = ["${var.redshift_role_arn}"]
}
