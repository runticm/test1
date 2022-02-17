module "db" {
  count = var.hasDb ? 1 : 0
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "~> 3.0"

  name           = "${var.project}-${var.env}"
  engine         = "aurora-postgresql"
  engine_version = "13.3"
  instance_type  = "db.t3.medium"

  vpc_id              = data.aws_ssm_parameter.vpc_id.value
  subnets             = split(",", data.aws_ssm_parameter.subnet_ids.value)
  replica_count       = var.dbReplicas
  storage_encrypted   = true
  apply_immediately   = true
  monitoring_interval = 10
  tags                = var.tags
  database_name       = var.dbName
  //iam_roles           = [aws_iam_role.stationProtocolAdapter.arn]
}

resource "aws_security_group_rule" "dbAllowFromEks" {
  count = var.hasDb ? 1 : 0
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = module.db[0].this_security_group_id
  type                     = "ingress"
  source_security_group_id = data.terraform_remote_state.common-platform.outputs.workerSecurityGroupId
  description              = "Allow from eks ${data.terraform_remote_state.common-platform.outputs.eksClusterName}"
}

resource "aws_ssm_parameter" "dbHost" {
  count = var.hasDb ? 1 : 0
  name  = "/${var.env}/${var.domain}/${var.project}/dbHost"
  type  = "String"
  value = module.db[0].this_rds_cluster_endpoint
  tags  = var.tags
}
resource "aws_ssm_parameter" "dbHostRo" {
  count = var.hasDb ? 1 : 0
  name  = "/${var.env}/${var.domain}/${var.project}/dbHostRo"
  type  = "String"
  value = module.db[0].this_rds_cluster_reader_endpoint
  tags  = var.tags
}
resource "aws_ssm_parameter" "dbUsername" {
  count = var.hasDb ? 1 : 0
  name  = "/${var.env}/${var.domain}/${var.project}/dbUsername"
  type  = "SecureString"
  value = module.db[0].this_rds_cluster_master_username
  tags  = var.tags
}
resource "aws_ssm_parameter" "dbPassword" {
  count = var.hasDb ? 1 : 0
  name  = "/${var.env}/${var.domain}/${var.project}/dbPassword"
  type  = "SecureString"
  value = module.db[0].this_rds_cluster_master_password
  tags  = var.tags
}
resource "aws_security_group_rule" "dbAllowFromBastionHost" {
  count = var.hasDb ? 1 : 0
  security_group_id = module.db[0].this_security_group_id
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  type              = "ingress"
  description = "allow from bastionHost"
  source_security_group_id = data.aws_ssm_parameter.bastionHost-securityGroupId.value
}