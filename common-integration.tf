locals {
  commonIntegrationMskClusterArn = data.terraform_remote_state.common-integration.outputs.mskClusterArn
  commonIntegrationMskClusterName = data.terraform_remote_state.common-integration.outputs.mskClusterName
  kafkaArnPrefix = "arn:aws:kafka:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}"
}
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource "aws_iam_role_policy_attachment" "accessToCommonIntegration" {
  count = var.allowAccessToCommonIntegration ? 1 :0
  policy_arn = aws_iam_policy.accessToCommonIntegration[0].arn
  role = aws_iam_role.pod.name
}

resource "aws_iam_policy" "accessToCommonIntegration" {
  count = var.allowAccessToCommonIntegration ? 1 :0
  name   = "${var.project}-accessToCommonIntegration-${var.env}"
  policy = data.aws_iam_policy_document.accessToCommonIntegration[0].json
}

data "aws_iam_policy_document" "accessToCommonIntegration" {
  count = var.allowAccessToCommonIntegration ? 1 :0
  statement {
    effect    = "Allow"
    actions   = ["kafka-cluster:Connect", "kafka-cluster:AlterCluster", "kafka-cluster:DescribeCluster"]
    resources = [local.commonIntegrationMskClusterArn]
    sid       = "connect"
  }
  statement {
    sid       = "groups"
    effect    = "Allow"
    actions   = ["kafka-cluster:AlterGroup", "kafka-cluster:DescribeGroup", "kafka-cluster:CreateGroup"]
    resources = [for n in var.allowedKafkaGroups : "${local.kafkaArnPrefix}:group/${local.commonIntegrationMskClusterName}/${n}"]
  }
  statement {
    sid       = "readFromTopics"
    effect    = "Allow"
    actions   = ["kafka-cluster:ReadData"]
    resources = [for n in var.allowedKafkaTopicsToRead : "${local.kafkaArnPrefix}:topic/${local.commonIntegrationMskClusterName}/${n}"]
  }
  statement {
    sid       = "writeToTopics"
    effect    = "Allow"
    actions   = ["kafka-cluster:WriteData", "kafka-cluster:CreateTopic"]
    resources = [for n in var.allowedKafkaTopicsToWrite : "${local.kafkaArnPrefix}:topic/${local.commonIntegrationMskClusterName}/${n}"]
  }
}