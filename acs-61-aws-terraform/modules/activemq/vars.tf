### ActiveMQ ###
variable "repo-security-group" {
  type = "string"
  description = "Repo security group to access the DB"
}
variable "solr-security-group" {
  type = "string"
  description = "Solr security group to access the DB"
}
variable "private-subnet-1-id" {
  type = "string"
  description = "Private subnet 1 id"
}
variable "private-subnet-2-id" {
  type = "string"
  description = "Private subnet 2 id"
}
variable "mq-user" {
  type = "string"
  description = "ActiveMQ user"
}
variable "mq-password" {
  type = "string"
  description = "ActiveMQ password"
}
### Resource prefix ##
variable "resource-prefix" {
  type = "string"
  description = "Prefix name to identify resources"
}