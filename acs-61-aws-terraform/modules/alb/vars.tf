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
### Resource prefix ##
variable "resource-prefix" {
  type = "string"
  description = "Prefix name to identify resources"
}
