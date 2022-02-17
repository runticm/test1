resource "aws_route53_record" "endpoint" {
  count = var.hasEndpoint && var.isEndpointPublic ? 1 : 0
  name    = "${var.project}.${var.env}.${data.terraform_remote_state.common-platform.outputs.accountZoneName}"
  type    = "CNAME"
  zone_id = data.terraform_remote_state.common-platform.outputs.accountZoneId
  records = [var.routeTo == "traefik" ? data.terraform_remote_state.common-platform.outputs.ingressBaseDomain : data.terraform_remote_state.common-platform.outputs.kongDomain]
  ttl     = 60
}
resource "aws_ssm_parameter" "endpoint" {
  count = var.hasEndpoint ? 1 : 0
  name  = "/${var.env}/${var.domain}/${var.project}/endpoint"
  type  = "String"
  value = var.isEndpointPublic ? "https://${aws_route53_record.endpoint[0].fqdn}" : "http://${var.project}.${data.aws_ssm_parameter.k8s_namespace.value}"
  tags  = var.tags
}
resource "aws_ssm_parameter" "host" {
  count = var.hasEndpoint ? 1 : 0
  name  = "/${var.env}/${var.domain}/${var.project}/host"
  type  = "String"
  value = var.isEndpointPublic ? aws_route53_record.endpoint[0].fqdn : "${var.project}.${data.aws_ssm_parameter.k8s_namespace.value}"
  tags  = var.tags
}