
variable "name" {
  description = "Name prefix for all EFS resources."
  default     = "App"
}

variable "access_sg_ids" {
  description = "A list of security groups Ids to grant access."
  type        = "list"
  default     = []
}

variable "subnets" {
  description = "A list of subnets to associate with."
  type        = "list"
  default     = []
}

variable "vpc_id" {
  description = "VPC Id where the EFS resources will be deployed."
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  default     = {}
}

variable "security_group_id" {
  description = "Workers security group."
  default     = ""
}