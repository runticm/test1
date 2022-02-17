output "serviceAccountName" {
  value = local.serviceAccountName
}
output "db_host" {
  value = try(module.db[0].this_rds_cluster_endpoint, "")
}
output "db_host_ro" {
  value = try(module.db[0].this_rds_cluster_reader_endpoint, "")
}
output "db_username" {
  value     = try(module.db[0].this_rds_cluster_master_username, "")
  sensitive = true
}
output "db_password" {
  value     = try(module.db[0].this_rds_cluster_master_password, "")
  sensitive = true
}
output "db_name" {
  value = var.dbName
}
output "db_sg_id" {
  value = try(module.db[0].this_security_group_id, "")
}
output "ecr_url" {
  value = aws_ecr_repository.repo.repository_url
}
output "endpoint" {
  value = try(nonsensitive(aws_ssm_parameter.endpoint[0].value), "")
}
output "ingressHost" {
  value = try(nonsensitive(aws_ssm_parameter.host[0].value), "")
}
output "roleArn" {
  value = aws_iam_role.pod.arn
}
output "k8s_namespace" {
  value = data.aws_ssm_parameter.k8s_namespace.value
}
output "k8s_cluster_name" {
  value = data.terraform_remote_state.common-platform.outputs.eksClusterName
}
output "kafka_brokers" {
  value = data.terraform_remote_state.common-integration.outputs.brokers
}
output "kafka_brokers_tls" {
  value = data.terraform_remote_state.common-integration.outputs.brokers_tls
}
output "kafka_brokers_iam" {
  value = data.terraform_remote_state.common-integration.outputs.brokers_iam
}
output "redis_host" {
  value     = try(module.redis[0].endpoint, "")
}
output "redis_authToken" {
  value     = try(random_password.redisAuthToken[0].result, "")
  sensitive = true
}
output "redis_port" {
  value     = try(module.redis[0].port, "")
}