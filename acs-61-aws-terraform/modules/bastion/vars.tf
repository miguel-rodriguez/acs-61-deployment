### VPC ###
variable "vpc-id" {
  type = "string"
  description = "VPC id"
}
variable "public-subnet-1-id" {
  type = "string"
  description = "Public subnet 1 id"
}
variable "public-subnet-2-id" {
  type = "string"
  description = "Public subnet 2 id"
}
### Key ###
variable "autoscaling-group-key-name" {
  type = "string"
  description = "Key name to access instance"
}
### Resource prefix ##
variable "resource-prefix" {
  type = "string"
  description = "Prefix name to identify resources"
}
### Image ###
variable "bastion-image-id" {
  type = "string"
  description = "Bastion image id"
}