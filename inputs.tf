variable "project" { type = string }
variable "env" { type = string }
variable "tags" { type = map(string) }
variable "domain" { type = string }
variable "routeTo" {
  type = string
  default = "traefik"
  validation {
    condition = contains(["traefik", "kong"], var.routeTo)
    error_message = "Can only route to traefik or kong."
  }
}
variable "hasDb" {
  type = bool
  default = true
}
variable "dbName" {
  type = string
  default = null
}
variable "dbReplicas" {
  type = number
  default = 1
}
variable "allowAccessToCommonIntegration" {
  type = bool
  default = false
}
variable "allowedKafkaTopicsToRead" {
  type = list(string)
  default = []
}
variable "allowedKafkaTopicsToWrite" {
  type = list(string)
  default = []
}
variable "allowedKafkaGroups" {
  type = list(string)
  default = ["*"]
}
variable "hasRedis" {
  type = bool
  default = false
}
variable "hasEndpoint" {
  type = bool
  default = true
}
variable "isEndpointPublic" {
  type = bool
  default = true
}