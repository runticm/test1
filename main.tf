data "aws_ssm_parameter" "k8s_namespace" {
  name = "/${var.env}/${var.domain}/k8s_namespace"
}
data "aws_ssm_parameter" "vpc_id" {
  name = "/${var.env}/integration-components/stage-network/vpc_id"
}
data "aws_ssm_parameter" "bastionHost-securityGroupId" {
  name = "/${var.env}/integration-components/stage-network/bastionHost-securityGroupId"
}
data "aws_ssm_parameter" "subnet_ids" {
  name = "/${var.env}/${var.domain}/subnet_ids"
}

data "terraform_remote_state" "common-platform" {
  backend = "s3"
  config = {
    bucket         = data.aws_ssm_parameter.terraformStateBucket.value
    dynamodb_table = data.aws_ssm_parameter.terraformStateLock.value
    key            = "integration-components/common-platform"
    region         = "eu-central-1"
    encrypt        = true
  }
  workspace = var.env
}
data "aws_ssm_parameter" "terraformStateBucket" {
  name = "terraformStateBucket"
}
data "aws_ssm_parameter" "terraformStateLock" {
  name = "terraformStateLock"
}

data "terraform_remote_state" "common-integration" {
  backend = "s3"
  config = {
    bucket         = data.aws_ssm_parameter.terraformStateBucket.value
    dynamodb_table = data.aws_ssm_parameter.terraformStateLock.value
    key            = "integration-components/common-integration"
    region         = "eu-central-1"
    encrypt        = true
  }
  workspace = var.env
}