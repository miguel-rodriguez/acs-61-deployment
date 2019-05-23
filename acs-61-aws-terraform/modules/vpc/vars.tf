### VPC ###
variable "aws-availability-zones" {
  type = "string"
  description = "AWS zones"
}
variable "vpc-cidr" {
  type = "string"
  description = "VPC CIDR"
}
### Resource prefix ##
variable "resource-prefix" {
  type = "string"
  description = "Prefix name to identify resources"
}

