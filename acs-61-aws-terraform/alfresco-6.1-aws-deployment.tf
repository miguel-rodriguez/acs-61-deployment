terraform {
  backend "s3" {
    # Replace this with your bucket name!
    bucket         = "mr-terraform-state-storage"
    key            = "global/s3/terraform.tfstate"
    region         = "eu-west-2"
    # Replace this with your DynamoDB table name!
    dynamodb_table = "mr-terraform-state-lock"
    encrypt        = true
  }
}

# Set a Provider
provider "aws" {
  region = "${var.aws-region}"
}

### VPC module ###
module "vpc" {
  source = "modules/vpc"

  # Input variables for vpc
  resource-prefix = "${var.resource-prefix}"
  vpc-cidr = "${var.vpc-cidr}"
  aws-availability-zones = "${var.aws-availability-zones}"
}

### RDS modlue ###
module "rds" {
  source = "modules/rds"

  # Input variables for rds
  resource-prefix = "${var.resource-prefix}"
  vpc-id = "${module.vpc.vpc-id}"
  rds-name = "${var.rds-name}"
  rds-engine = "${var.rds-engine}"
  rds-username = "${var.rds-username}"
  rds-password = "${var.rds-password}"
  rds-port = "${var.rds-port}"
  rds-storage-type = "${var.rds-storage-type}"
  rds-instance-class = "${var.rds-instance-class}"
  rds-storage-size = "${var.rds-storage-size}"
  rds-engine-version = "${var.rds-engine-version}"
  private-subnet-1-id = "${module.vpc.private-subnet-1-id}"
  private-subnet-2-id = "${module.vpc.private-subnet-2-id}"
  rds-repo-security-group = "${module.alfresco-repo.alfresco-sg-id}"
  rds-solr-security-group = "${module.alfresco-solr.alfresco-sg-id}"
}

### Alfresco repo module ###
module "alfresco-repo" {
  source = "modules/alfresco-repo"

  # Input variables for alfresco
  resource-prefix = "${var.resource-prefix}"
  vpc-id = "${module.vpc.vpc-id}"
  vpc-default-sg-id = "${module.vpc.vpc-default-sg-id}"
  private-subnet-1-id = "${module.vpc.private-subnet-1-id}"
  private-subnet-2-id = "${module.vpc.private-subnet-2-id}"
  rds-name = "${var.rds-name}"
  rds-username = "${var.rds-username}"
  rds-password = "${var.rds-password}"
  rds-port = "${var.rds-port}"  
  rds-driver = "${var.rds-driver}"  
  rds-endpoint = "${module.rds.rds-endpoint}"
  alb-name = "${module.alb.alb-name}"
  alb-dns = "${module.alb.alb-dns}"
  alb-sg-id = "${module.alb.alb-security-group-id}"
  autoscaling-group-max-size = "${var.autoscaling-repo-group-max-size}"
  autoscaling-group-min-size = "${var.autoscaling-repo-group-min-size}"
  autoscaling-group-desired-capacity = "${var.autoscaling-repo-group-desired-capacity}"
  autoscaling-group-key-name = "${var.autoscaling-group-key-name}"
  autoscaling-group-instance-type = "${var.autoscaling-repo-group-instance-type}"
  autoscaling-group-image-id = "${var.autoscaling-repo-group-image-id}"
  s3-bucket-location = "${var.s3-bucket-location}"
  solr-ebs-volume-size = "${var.solr-ebs-volume-size}"
  cachedcontent-ebs-volume-size = "${var.cachedcontent-ebs-volume-size}"
  alb-arn = "${module.alb.alb-arn}"
  alb-listener-arn = "${module.alb.alb-listener-arn}"
  internal-nlb-arn = "${module.internal-nlb.internal-nlb-arn}"
  internal-nlb-dns = "${module.internal-nlb.internal-nlb-dns}" 
  mq-ssl-endpoint-1 = "${module.activemq.ssl-endpoint-1}"
  mq-ssl-endpoint-2 = "${module.activemq.ssl-endpoint-2}"
  mq-user = "${var.mq-user}"
  mq-password = "${var.mq-password}" 
  jod-converter-port = "${var.jod-converter-port}"
  pdf-renderer-port = "${var.pdf-renderer-port}"
  image-magick-port = "${var.image-magick-port}"
  tika-port = "${var.tika-port}"
  shared-file-store-port = "${var.shared-file-store-port}"
}

### Alfresco solr module ###
module "alfresco-solr" {
  source = "modules/alfresco-solr"

  # Input variables for alfresco
  resource-prefix = "${var.resource-prefix}"
  vpc-id = "${module.vpc.vpc-id}"
  vpc-default-sg-id = "${module.vpc.vpc-default-sg-id}"
  private-subnet-1-id = "${module.vpc.private-subnet-1-id}"
  private-subnet-2-id = "${module.vpc.private-subnet-2-id}"
  rds-name = "${var.rds-name}"
  rds-username = "${var.rds-username}"
  rds-password = "${var.rds-password}"
  rds-port = "${var.rds-port}"  
  rds-driver = "${var.rds-driver}"  
  rds-endpoint = "${module.rds.rds-endpoint}"
  alb-name = "${module.alb.alb-name}"
  alb-dns = "${module.alb.alb-dns}"
  alb-sg-id = "${module.alb.alb-security-group-id}"
  autoscaling-group-max-size = "${var.autoscaling-solr-group-max-size}"
  autoscaling-group-min-size = "${var.autoscaling-solr-group-min-size}"
  autoscaling-group-desired-capacity = "${var.autoscaling-solr-group-desired-capacity}"
  autoscaling-group-key-name = "${var.autoscaling-group-key-name}"
  autoscaling-group-instance-type = "${var.autoscaling-solr-group-instance-type}"
  autoscaling-group-image-id = "${var.autoscaling-solr-group-image-id}"
  s3-bucket-location = "${var.s3-bucket-location}"
  solr-ebs-volume-size = "${var.solr-ebs-volume-size}"
  cachedcontent-ebs-volume-size = "${var.cachedcontent-ebs-volume-size}"
  alb-arn = "${module.alb.alb-arn}"
  alb-listener-arn = "${module.alb.alb-listener-arn}"
  internal-nlb-arn = "${module.internal-nlb.internal-nlb-arn}"
  internal-nlb-dns = "${module.internal-nlb.internal-nlb-dns}"
  mq-ssl-endpoint-1 = "${module.activemq.ssl-endpoint-1}"
  mq-ssl-endpoint-2 = "${module.activemq.ssl-endpoint-2}"
  mq-user = "${var.mq-user}"
  mq-password = "${var.mq-password}"
  jod-converter-port = "${var.jod-converter-port}"
  pdf-renderer-port = "${var.pdf-renderer-port}"
  image-magick-port = "${var.image-magick-port}"
  tika-port = "${var.tika-port}"
  shared-file-store-port = "${var.shared-file-store-port}"  
}

### Transformation Service module ###
module "transformation-service" {
  source = "modules/transformation-service"

  # Input variables for transformation services
  resource-prefix = "${var.resource-prefix}"
  vpc-id = "${module.vpc.vpc-id}"
  vpc-default-sg-id = "${module.vpc.vpc-default-sg-id}"
  private-subnet-1-id = "${module.vpc.private-subnet-1-id}"
  private-subnet-2-id = "${module.vpc.private-subnet-2-id}"
  alb-name = "${module.alb.alb-name}"
  alb-dns = "${module.alb.alb-dns}"
  alb-sg-id = "${module.alb.alb-security-group-id}"
  autoscaling-group-max-size = "${var.autoscaling-ts-group-max-size}"
  autoscaling-group-min-size = "${var.autoscaling-ts-group-min-size}"
  autoscaling-group-desired-capacity = "${var.autoscaling-ts-group-desired-capacity}"
  autoscaling-group-key-name = "${var.autoscaling-group-key-name}"
  autoscaling-group-instance-type = "${var.autoscaling-ts-group-instance-type}"
  autoscaling-group-image-id = "${var.autoscaling-ts-group-image-id}"
  alb-arn = "${module.alb.alb-arn}"
  alb-listener-arn = "${module.alb.alb-listener-arn}"
  internal-nlb-arn = "${module.internal-nlb.internal-nlb-arn}"
  internal-nlb-dns = "${module.internal-nlb.internal-nlb-dns}"
  mq-ssl-endpoint-1 = "${module.activemq.ssl-endpoint-1}"
  mq-ssl-endpoint-2 = "${module.activemq.ssl-endpoint-2}"
  mq-user = "${var.mq-user}"
  mq-password = "${var.mq-password}"
  efs-dns = "${module.efs.dns_name}"
  ansible_alfresco_user = "${var.ansible_alfresco_user}"
  ansible_libreoffice_port = "${var.ansible_libreoffice_port}"
  ansible_libreoffice_java_mem_opts = "${var.ansible_libreoffice_java_mem_opts}"
  ansible_pdf_renderer_port = "${var.ansible_pdf_renderer_port}"
  ansible_pdf_renderer_java_mem_opts = "${var.ansible_pdf_renderer_java_mem_opts}"
  ansible_imagemagick_port = "${var.ansible_imagemagick_port}"
  ansible_imagemagick_java_mem_opts = "${var.ansible_imagemagick_java_mem_opts}"
  ansible_tika_port = "${var.ansible_tika_port}"
  ansible_tika_java_mem_opts = "${var.ansible_tika_java_mem_opts}"
  ansible_shared_file_store_port = "${var.ansible_shared_file_store_port}"
  ansible_shared_file_store_java_mem_opts = "${var.ansible_shared_file_store_java_mem_opts}"
  ansible_shared_file_store_path = "${var.ansible_shared_file_store_path}"
  ansible_transform_router_port = "${var.ansible_transform_router_port}"
  ansible_transform_router_java_mem_opts = "${var.ansible_transform_router_java_mem_opts}"
}

### Bastion node module ###
module "bastion" {
  source = "modules/bastion"

  # Input variables for bastion node
  resource-prefix = "${var.resource-prefix}"
  vpc-id = "${module.vpc.vpc-id}"
  bastion-image-id = "${var.bastion-image-id}"
  public-subnet-1-id = "${module.vpc.public-subnet-1-id}"
  public-subnet-2-id = "${module.vpc.public-subnet-2-id}"
  autoscaling-group-key-name = "${var.autoscaling-group-key-name}"
}

### ALB module ###
module "alb" {
  source = "modules/alb"

  # Input variables for alb
  resource-prefix = "${var.resource-prefix}"
  vpc-id = "${module.vpc.vpc-id}"
  public-subnet-1-id = "${module.vpc.public-subnet-1-id}"
  public-subnet-2-id = "${module.vpc.public-subnet-2-id}"
}

### Internal ALB module ###
module "internal-nlb" {
  source = "modules/internal-nlb"

  # Input variables for alb
  resource-prefix = "${var.resource-prefix}"
  vpc-id = "${module.vpc.vpc-id}"
  public-subnet-1-id = "${module.vpc.public-subnet-1-id}"
  public-subnet-2-id = "${module.vpc.public-subnet-2-id}"
}

### ActiveMQ module ###
module "activemq" {
  source = "modules/activemq"

  # Input variables for alb
  resource-prefix = "${var.resource-prefix}"
  repo-security-group = "${module.alfresco-repo.alfresco-sg-id}"
  solr-security-group = "${module.alfresco-solr.alfresco-sg-id}"
  private-subnet-1-id = "${module.vpc.private-subnet-1-id}"
  private-subnet-2-id = "${module.vpc.private-subnet-2-id}"
  mq-user = "${var.mq-user}"
  mq-password = "${var.mq-password}"
}

# EFS storage for Alfresco
module "efs" {
  source  = "modules/efs"

  name    = "${var.resource-prefix}-efs"
  vpc_id  = "${module.vpc.vpc-id}"
  subnets = ["${module.vpc.private-subnet-1-id}", "${module.vpc.private-subnet-2-id}"]
  security_group_id = "${module.transformation-service.ts-sg-id}"
}