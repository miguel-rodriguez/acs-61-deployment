### RDS ###
variable "rds-storage-size" {
  type = "string"
  description = "Storage size in GB"
}
variable "rds-storage-type" {
  type = "string"
  description = "Storage type"
}
variable "rds-engine" {
  type = "string"
  description = "RDS type"
}
variable "rds-engine-version" {
  type = "string"
  description = "RDS version"
}
variable "rds-instance-class" {
  type = "string"
  description = "RDS instance class"
}
variable "rds-username" {
  type = "string"
  description = "RDS username"
}
variable "rds-password" {
  type = "string"
  description = "RDS password"
}
variable "rds-port" {
  type = "string"
  description = "RDS port number"
}
variable "rds-name" {
  type = "string"
  description = "Alfresco DB Name"
}
variable "rds-repo-security-group" {
  type = "string"
  description = "Repo security group to access the DB"
}
variable "rds-solr-security-group" {
  type = "string"
  description = "Solr security group to access the DB"
}### VPC ###
variable "vpc-id" {
  type = "string"
  description = "VPC id"
}
variable "private-subnet-1-id" {
  type = "string"
  description = "Private subnet 1 id"
}
variable "private-subnet-2-id" {
  type = "string"
  description = "Private subnet 2 id"
}
### Resource prefix ##
variable "resource-prefix" {
  type = "string"
  description = "Prefix name to identify resources"
}

