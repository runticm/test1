data "aws_availability_zones" "zones" {
  count = var.hasRedis ? 1 : 0
}
resource "random_password" "redisAuthToken" {
  count = var.hasRedis ? 1 : 0
  length = 20
}

module "redis" {
  count = var.hasRedis ? 1 : 0
  source = "cloudposse/elasticache-redis/aws"
  version = "0.40.1"
  availability_zones         = data.aws_availability_zones.zones[0].names
  namespace                  = var.project
  stage                      = var.env
  vpc_id                     = data.aws_ssm_parameter.vpc_id.value
  subnets                    = split(",", data.aws_ssm_parameter.subnet_ids.value)
  cluster_size               = 1
  instance_type              = "cache.t3.small"
  apply_immediately          = true
  automatic_failover_enabled = false
  at_rest_encryption_enabled = false
  transit_encryption_enabled = false
  family = "redis6.x"
  engine_version = "6.x"
  auth_token = random_password.redisAuthToken[0].result

  security_group_rules = [
    {
      type                     = "egress"
      from_port                = 0
      to_port                  = 65535
      protocol                 = "-1"
      cidr_blocks              = ["0.0.0.0/0"]
      source_security_group_id = null
      description              = "Allow all outbound traffic"
    },
    {
      type                     = "ingress"
      from_port                = 0
      to_port                  = 65535
      protocol                 = "-1"
      cidr_blocks              = []
      source_security_group_id = data.terraform_remote_state.common-platform.outputs.workerSecurityGroupId
      description              = "Allow from eks ${data.terraform_remote_state.common-platform.outputs.eksClusterName}"
    },
  ]

  parameter = [
    {
      name  = "notify-keyspace-events"
      value = "lK"
    }
  ]

  tags = var.tags
}

resource "aws_ssm_parameter" "redisHost" {
  count = var.hasRedis ? 1 : 0
  name  = "/${var.env}/${var.domain}/${var.project}/redisHost"
  type  = "String"
  value = module.redis[0].endpoint
  tags  = var.tags
}
resource "aws_ssm_parameter" "redisPort" {
  count = var.hasRedis ? 1 : 0
  name  = "/${var.env}/${var.domain}/${var.project}/redisPort"
  type  = "String"
  value = module.redis[0].endpoint
  tags  = var.tags
}
resource "aws_ssm_parameter" "redisAuthToken" {
  count = var.hasRedis ? 1 : 0
  name  = "/${var.env}/${var.domain}/${var.project}/redisAuthToken"
  type  = "SecureString"
  value = random_password.redisAuthToken[0].result
  tags  = var.tags
}
resource "aws_security_group_rule" "redisAllowFromBastionHost" {
  count = var.hasRedis ? 1 : 0
  security_group_id = module.redis[0].security_group_id
  from_port         = module.redis[0].port
  to_port           = module.redis[0].port
  protocol          = "tcp"
  type              = "ingress"
  description = "allow from bastionHost"
  source_security_group_id = data.aws_ssm_parameter.bastionHost-securityGroupId.value
}