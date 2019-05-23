### Auto scaling ###
variable "autoscaling-group-max-size" {
  type = "string"
  description = "Maximun number of instances"
}
variable "autoscaling-group-min-size" {
  type = "string"
  description = "Minimum number of instances"
}
variable "autoscaling-group-desired-capacity" {
  type = "string"
  description = "Desired number of instances"
}
variable "autoscaling-group-key-name" {
  type = "string"
  description = "Key name to access instance"
}
variable "autoscaling-group-instance-type" {
  type = "string"
  description = "EC2 instance type"
}
variable "autoscaling-group-image-id" {
  type = "string"
  description = "Alfresco EC2 image id"
}
variable "solr-ebs-volume-size" {
  type = "string"
  description = "Solr indexes volume size"
}
variable "cachedcontent-ebs-volume-size" {
  type = "string"
  description = "Caching content store volume size"
}

### S3 bucket ###
variable "s3-bucket-location" {
  type = "string"
  description = "S3 bucket location"
}

### VPC ###
variable "vpc-id" {
  type = "string"
  description = "VPC id"
}
variable "vpc-default-sg-id" {
  type = "string"
  description = "VPC default SG id"
}
variable "private-subnet-1-id" {
  type = "string"
  description = "Private subnet 1 id"
}
variable "private-subnet-2-id" {
  type = "string"
  description = "Private subnet 2 id"
}
### RDS ###
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
  description = "Alfresco DB name"
}
variable "rds-driver" {
  type = "string"
  description = "Alfresco DB driver name"
}
variable "rds-endpoint" {
  type = "string"
  description = "RDS end point (URL + port)"
}
### ALB ###
variable "alb-name" {
  type = "string"
  description = "ALB name"
}
variable "alb-dns" {
  type = "string"
  description = "ALB DNS name"
}
variable "alb-sg-id" {
  type = "string"
  description = "ALB security group id"
}
variable "alb-arn" {
  type = "string"
  description = "ALB arn id"
}
variable "alb-listener-arn" {
  type = "string"
  description = "ALB listener arn"
}### Internal ALB ###
variable "internal-nlb-dns" {
  type = "string"
  description = "Internal ALB DNS name"
}
variable "internal-nlb-arn" {
  type = "string"
  description = "Internal ALB arn id"
}
### ActiveMQ ###
variable "mq-ssl-endpoint-1" {
  type = "string"
  description = "ActiveMQ SSL endpoint"
}
variable "mq-ssl-endpoint-2" {
  type = "string"
  description = "ActiveMQ SSL endpoint"
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
### Transformation Services ###
variable "jod-converter-port" {
  type = "string"
  description = "Libreoffice port"
}
variable "pdf-renderer-port" {
  type = "string"
  description = "PDF renderer port"
}
variable "image-magick-port" {
  type = "string"
  description = "Image magick port"
}
variable "tika-port" {
  type = "string"
  description = "Tika port"
}
variable "shared-file-store-port" {
  type = "string"
  description = "Shared file store port"
}