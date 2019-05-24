### Resources tagging - use <initials>-<project>###
resource-prefix="mr-acs-61"
### AWS variables ###
aws-region = "eu-west-2"
vpc-cidr = "10.0.0.0/16"
vpc-name = "test-terraform-vpc"
aws-availability-zones = "eu-west-2a,eu-west-2b"
### Alfresco common variables ###
autoscaling-group-key-name = "MiguelRodriguezLondon"
s3-bucket-location = "eu-west-2"
cachedcontent-ebs-volume-size = "50"
### Alfresco Repo variables ###
autoscaling-repo-group-image-id = "ami-05ef8434cdba67b45"
autoscaling-repo-group-instance-type = "m4.xlarge"
autoscaling-repo-group-max-size = "2"
autoscaling-repo-group-desired-capacity = "1"
autoscaling-repo-group-min-size = "0"
jod-converter-port=8090
pdf-renderer-port=8091
image-magick-port=8092
tika-port=8093
shared-file-store-port=8094
### Alfresco Solr variables ###
autoscaling-solr-group-image-id = "ami-07f76be6c456a4e0d"
autoscaling-solr-group-instance-type = "m4.xlarge"
autoscaling-solr-group-max-size = "2"
autoscaling-solr-group-desired-capacity = "1"
autoscaling-solr-group-min-size = "0"
solr-ebs-volume-size = "100"
jod-converter-port=8090
pdf-renderer-port=8091
image-magick-port=8092
tika-port=8093
shared-file-store-port=8094
### Transformation Service variables ###
autoscaling-ts-group-image-id = "ami-0d3bd15c5b3145304"
autoscaling-ts-group-instance-type = "m4.xlarge"
autoscaling-ts-group-max-size = "2"
autoscaling-ts-group-desired-capacity = "1"
autoscaling-ts-group-min-size = "0"
solr-ebs-volume-size = "50"
ansible_alfresco_user= "alfresco"
ansible_libreoffice_port = "8090"
ansible_libreoffice_java_mem_opts = "-Xms512m -Xmx512m"
ansible_pdf_renderer_port = "8091"
ansible_pdf_renderer_java_mem_opts = "-Xms128m -Xmx128m"
ansible_imagemagick_port = "8092"
ansible_imagemagick_java_mem_opts = "-Xms256m -Xmx256m"
ansible_tika_port = "8093"
ansible_tika_java_mem_opts = "-Xms256m -Xmx256m"
ansible_shared_file_store_port = "8094"
ansible_shared_file_store_java_mem_opts ="-Xms256m -Xmx256m"
ansible_shared_file_store_path = "/opt/efs"
ansible_transform_router_port = "8095"
ansible_transform_router_java_mem_opts = "-Xms512m -Xmx512m"
### Database varaibles ###
rds-engine = "mysql"
rds-engine-version = "5.7.19"
rds-instance-class = "db.r4.xlarge"
rds-storage-size = "5"
rds-storage-type = "gp2"
rds-username = "alfresco"
rds-password = "admin2019"
rds-driver = "org.gjt.mm.mysql.Driver"
rds-port = "3306"
rds-name = "alfresco"
s3-bucket-location = "eu-west-2"
### Bastion node ###
bastion-image-id="ami-0664a710233d7c148"
### ActiveMQ ###
mq-user = "alfresco"
mq-password = "!Alfresco2019"