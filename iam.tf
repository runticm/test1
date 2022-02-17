locals {
  serviceAccountName = var.project
}
resource "aws_iam_role" "pod" {
  name = "${local.serviceAccountName}-${var.env}"
  tags = merge(var.tags, {
    Name = "${local.serviceAccountName}-${var.env}"
  })
  assume_role_policy = data.aws_iam_policy_document.podAssumeRole.json
}

data "aws_iam_policy_document" "podAssumeRole" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [data.terraform_remote_state.common-platform.outputs.oidcProviderArn]
    }

    condition {
      test     = "StringEquals"
      variable = "${data.terraform_remote_state.common-platform.outputs.oidcIssuer}:sub"
      values   = ["system:serviceaccount:${data.aws_ssm_parameter.k8s_namespace.value}:${local.serviceAccountName}"]
    }
  }
}

resource "kubernetes_service_account" "pod" {
  metadata {
    name      = local.serviceAccountName
    namespace = data.aws_ssm_parameter.k8s_namespace.value
    annotations = {
      "eks.amazonaws.com/role-arn" : aws_iam_role.pod.arn
    }
  }
}