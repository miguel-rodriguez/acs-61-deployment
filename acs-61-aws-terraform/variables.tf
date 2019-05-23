### VPC ###
variable "aws-region" {
  type = "string"
  description = "AWS region"
}
variable "aws-availability-zones" {
  type = "string"
  description = "AWS zones"
}
variable "vpc-cidr" {
  type = "string"
  description = "VPC CIDR"
}
variable "vpc-name" {
  type = "string"
  description = "VPC name"
}

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

### Alfresco ###
variable "autoscaling-repo-group-min-size" {
  type = "string"
  description = "Min size of the ASG"
}
variable "autoscaling-repo-group-max-size" {
  type = "string"
  description = "Max size of the ASG"
}
variable "autoscaling-repo-group-desired-capacity" {
  type = "string"
  description = "Desired size of the ASG"
}
variable "autoscaling-repo-group-image-id" {
  type="string"
  description = "EC2 AMI identifier"
}
variable "autoscaling-repo-group-instance-type" {
  type = "string"
  description = "EC2 instance type"
}
variable "autoscaling-group-key-name" {
  type = "string"
  description = "EC2 ssh key name"
}
variable "rds-name" {
  type = "string"
  description = "Alfresco DB Name"
}
variable "rds-driver" {
  type = "string"
  description = "DB Driver"
}
variable "s3-bucket-location" {
  type = "string"
  description = "Alfresco repo S3 bucket location"
}
variable "cachedcontent-ebs-volume-size" {
  type = "string"
  description = "Caching content store volume size"
}
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
### Alfresco Solr ###
variable "autoscaling-solr-group-min-size" {
  type = "string"
  description = "Min size of the ASG"
}
variable "autoscaling-solr-group-max-size" {
  type = "string"
  description = "Max size of the ASG"
}
variable "autoscaling-solr-group-desired-capacity" {
  type = "string"
  description = "Desired size of the ASG"
}
variable "autoscaling-solr-group-image-id" {
  type="string"
  description = "EC2 AMI identifier"
}
variable "autoscaling-solr-group-instance-type" {
  type = "string"
  description = "EC2 instance type"
}
variable "solr-ebs-volume-size" {
  type = "string"
  description = "Solr indexes volume size"
}

### Transformation Service ###
variable "autoscaling-ts-group-min-size" {
  type = "string"
  description = "Min size of the ASG"
}
variable "autoscaling-ts-group-max-size" {
  type = "string"
  description = "Max size of the ASG"
}
variable "autoscaling-ts-group-desired-capacity" {
  type = "string"
  description = "Desired size of the ASG"
}
variable "autoscaling-ts-group-image-id" {
  type="string"
  description = "EC2 AMI identifier"
}
variable "autoscaling-ts-group-instance-type" {
  type = "string"
  description = "EC2 instance type"
}
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
variable "ansible_shared_file_store_java_mem_opts" {
  type = "string"
  description = "Shared file store java memory options"
}
variable "ansible_shared_file_store_path" {
  type = "string"
  description = "Shared file store path"
}
variable "ansible_transform_router_port" {
  type = "string"
  description = "Transform router port"
}
variable "ansible_transform_router_java_mem_opts" {
  type = "string"
  description = "Transform router java memory options"
}

### Bastion node ###
variable "bastion-image-id" {
  type = "string"
  description = "Bastion node image id"
}

### Resources prefix tagging ##
variable "resource-prefix" {
  type = "string"
  description = "Prefix name to identify resources"
}

### Active MQ ###
variable "mq-user" {
  type = "string"
  description = "ActiveMQ user"
}
variable "mq-password" {
  type = "string"
  description = "ActiveMQ password"
}