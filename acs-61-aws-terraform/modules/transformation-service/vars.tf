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
}

### Internal ALB ###
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

### EFS ##
variable "efs-dns" {
  type = "string"
  description = "efs-dns"
}

### Transformers ###
variable "ansible_alfresco_user" {
  type = "string"
  description = "Alfresco user"
}
variable "ansible_libreoffice_port" {
  type = "string"
  description = "Libreoffice port"
}
variable "ansible_libreoffice_java_mem_opts" {
  type = "string"
  description = "Libreoffice java memory options"
}
variable "ansible_pdf_renderer_port" {
  type = "string"
  description = "PDF renderer port"
}
variable "ansible_pdf_renderer_java_mem_opts" {
  type = "string"
  description = "PDF renderer java memory options"
}
variable "ansible_imagemagick_port" {
  type = "string"
  description = "Image magick port"
}
variable "ansible_imagemagick_java_mem_opts" {
  type = "string"
  description = "Image magick java memory options"
}
variable "ansible_tika_port" {
  type = "string"
  description = "Tika port"
}
variable "ansible_tika_java_mem_opts" {
  type = "string"
  description = "Tika java memory options"
}
variable "ansible_shared_file_store_port" {
  type = "string"
  description = "Shared file store port"
}
variable "ansible_shared_file_store_path" {
  type = "string"
  description = "Shared file store path"
}
variable "ansible_shared_file_store_java_mem_opts" {
  type = "string"
  description = "Shared file store java memory options"
}
variable "ansible_transform_router_port" {
  type = "string"
  description = "Transform router port"
}
variable "ansible_transform_router_java_mem_opts" {
  type = "string"
  description = "Transform router java memory options"
}