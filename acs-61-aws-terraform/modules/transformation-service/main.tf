### URLs to be applied to alfresco-global.properties
locals {
  lb_url = "${var.alb-dns}"
  internal_lb_url = "${var.internal-nlb-dns}"
  mq_user = "${var.mq-user}"
  mq_password = "${var.mq-password}"
  mq_failover = "failover:(${var.mq-ssl-endpoint-1},${var.mq-ssl-endpoint-2})?timeout=30000"  
  efs_dns = "${var.efs-dns}"
}

### Alfresco with autoscaling ###
resource "aws_security_group" "alfresco-ts-sg" {
  name = "${var.resource-prefix}-ts-sg"
  description = "Alfresco instance security group"
  vpc_id = "${var.vpc-id}"

  ingress {
    from_port = "8090"
    to_port = "8094"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Transformation services"
  }

  ingress {
    from_port = "61617"
    to_port = "61617"
    protocol = "tcp"
    security_groups = ["${var.vpc-default-sg-id}"]
    description = "AmazonMQ"
  }

  ingress {
    from_port = "22"
    to_port = "22"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH"
  }

  ingress {
    from_port = "2049"
    to_port = "2049"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "EFS"
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.resource-prefix}-alfresco-ts-sg"
  }
}

# Launch configuration #
resource "aws_launch_configuration" "ts-lcfg" {
  name_prefix   = "${var.resource-prefix}-ts-lcfg"
  image_id = "${var.autoscaling-group-image-id}"
  instance_type = "${var.autoscaling-group-instance-type}"
  key_name = "${var.autoscaling-group-key-name}"
  security_groups = ["${aws_security_group.alfresco-ts-sg.id}"]

  user_data = <<-EOF
    #!/bin/bash
    sudo setenforce 0
    # mount efs
    sudo yum install -y nfs-utils
    sudo mkdir ${var.ansible_shared_file_store_path}
    sudo chown ${var.ansible_alfresco_user}:${var.ansible_alfresco_user} ${var.ansible_shared_file_store_path}
    sudo mount -t nfs -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${local.efs_dns}:/ /opt/efs
    sudo sed -i 's/@@ansible_activemq_url@@/failover:(${var.mq-ssl-endpoint-1},${var.mq-ssl-endpoint-2})?timeout=30000/g' /etc/init.d/transformation
    sudo sed -i 's/@@ansible_alfresco_user@@/${var.ansible_alfresco_user}/g' /etc/init.d/transformation
    sudo sed -i 's/@@ansible_libreoffice_port@@/${var.ansible_libreoffice_port}/g' /etc/init.d/transformation
    sudo sed -i 's/@@ansible_libreoffice_java_mem_opts@@/${var.ansible_libreoffice_java_mem_opts}/g' /etc/init.d/transformation
    sudo sed -i 's/@@ansible_pdf_renderer_port@@/${var.ansible_pdf_renderer_port}/g' /etc/init.d/transformation
    sudo sed -i 's/@@ansible_pdf_renderer_java_mem_opts@@/${var.ansible_pdf_renderer_java_mem_opts}/g' /etc/init.d/transformation
    sudo sed -i 's/@@ansible_imagemagick_port@@/${var.ansible_imagemagick_port}/g' /etc/init.d/transformation
    sudo sed -i 's/@@ansible_imagemagick_java_mem_opts@@/${var.ansible_imagemagick_java_mem_opts}/g' /etc/init.d/transformation
    sudo sed -i 's/@@ansible_tika_port@@/${var.ansible_tika_port}/g' /etc/init.d/transformation
    sudo sed -i 's/@@ansible_tika_java_mem_opts@@/${var.ansible_tika_java_mem_opts}/g' /etc/init.d/transformation
    sudo sed -i 's/@@ansible_shared_file_store_port@@/${var.ansible_shared_file_store_port}/g' /etc/init.d/transformation
    sudo sed -i 's/@@ansible_shared_file_store_java_mem_opts@@/${var.ansible_shared_file_store_java_mem_opts}/g' /etc/init.d/transformation
    sudo sed -i 's/@@ansible_shared_file_store_path@@/${var.ansible_shared_file_store_path}/g' /etc/init.d/transformation
    sudo sed -i 's/@@ansible_transform_router_port@@/${var.ansible_transform_router_port}/g' /etc/init.d/transformation
    sudo sed -i 's/@@ansible_transform_router_java_mem_opts@@/${var.ansible_transform_router_java_mem_opts}/g' /etc/init.d/transformation
    sudo sed -i 's/@@ansible_shared_file_store_path@@/${var.ansible_shared_file_store_path}/g' /etc/init.d/transformation
    sudo sed -i 's/@@ansible_activemq_url@@/${local.mq_failover}/g' /etc/init.d/transformation
    sudo sed -i 's/@@ansible_activemq_user@@/${var.mq-user}/g' /etc/init.d/transformation
    sudo sed -i 's/@@ansible_activemq_password@@/${var.mq-password}/g' /etc/init.d/transformation



declare -x ACTIVEMQ_PASSWORD="admin"
declare -x ACTIVEMQ_URL="nio://wobbly-kitten-activemq-broker:61616"
declare -x ACTIVEMQ_USER="admin"

    ### enable code deploy ###
    REGION=$(curl 169.254.169.254/latest/meta-data/placement/availability-zone/ | sed 's/[a-z]$//')
    sudo yum update -y
    sudo yum install -y ruby
    sudo yum install -y wget
    cd
    wget https://aws-codedeploy-$REGION.s3.amazonaws.com/latest/install
    sudo chmod +x ./install
    sudo ./install auto	
    EOF

  lifecycle {
    create_before_destroy = true
  }
}

# Auto scaling group #
resource "aws_autoscaling_group" "ts-asg" {
  name = "${var.resource-prefix}-ts-asg"
  launch_configuration = "${aws_launch_configuration.ts-lcfg.id}"
  vpc_zone_identifier = ["${var.private-subnet-1-id}", "${var.private-subnet-2-id}"]
  min_size = "${var.autoscaling-group-min-size}"
  max_size = "${var.autoscaling-group-max-size}"
  desired_capacity = "${var.autoscaling-group-desired-capacity}"
  target_group_arns = ["${aws_alb_target_group.libreoffice-target-group.arn}", "${aws_alb_target_group.pdf-target-group.arn}", "${aws_alb_target_group.imagick-target-group.arn}", "${aws_alb_target_group.tika-target-group.arn}", "${aws_alb_target_group.sfs-target-group.arn}", "${aws_alb_target_group.router-target-group.arn}"]

  tags {
    key = "Name"
    value = "${var.resource-prefix}-alfresco-ts"
    propagate_at_launch = true
  }
  depends_on = ["aws_autoscaling_group.ts-asg"]
}

# Connect applications to the Load Balancer
resource "aws_alb_target_group" "libreoffice-target-group" {
  name     = "${var.resource-prefix}-lo-target-group"
  port     = 8090
  protocol = "TCP"
  vpc_id   = "${var.vpc-id}"
  stickiness = []
}

resource "aws_alb_listener" "libreoffice-nlb-listener" {
  load_balancer_arn = "${var.internal-nlb-arn}"
  port              = "8090"
  protocol          = "TCP"

  default_action {
    target_group_arn = "${aws_alb_target_group.libreoffice-target-group.arn}"
    type             = "forward"
  }
}

resource "aws_alb_target_group" "pdf-target-group" {
  name     = "${var.resource-prefix}-pdf-target-group"
  port     = 8091
  protocol = "TCP"
  vpc_id   = "${var.vpc-id}"
  stickiness = []
}

resource "aws_alb_listener" "pdf-nlb-listener" {
  load_balancer_arn = "${var.internal-nlb-arn}"
  port              = "8091"
  protocol          = "TCP"

  default_action {
    target_group_arn = "${aws_alb_target_group.pdf-target-group.arn}"
    type             = "forward"
  }
}

resource "aws_alb_target_group" "imagick-target-group" {
  name     = "${var.resource-prefix}-imagick-target-group"
  port     = 8092
  protocol = "TCP"
  vpc_id   = "${var.vpc-id}"
  stickiness = []
}

resource "aws_alb_listener" "imagick-nlb-listener" {
  load_balancer_arn = "${var.internal-nlb-arn}"
  port              = "8092"
  protocol          = "TCP"

  default_action {
    target_group_arn = "${aws_alb_target_group.imagick-target-group.arn}"
    type             = "forward"
  }
}

resource "aws_alb_target_group" "tika-target-group" {
  name     = "${var.resource-prefix}-tika-target-group"
  port     = 8093
  protocol = "TCP"
  vpc_id   = "${var.vpc-id}"
  stickiness = []
}

resource "aws_alb_listener" "tika-nlb-listener" {
  load_balancer_arn = "${var.internal-nlb-arn}"
  port              = "8093"
  protocol          = "TCP"

  default_action {
    target_group_arn = "${aws_alb_target_group.tika-target-group.arn}"
    type             = "forward"
  }
}

resource "aws_alb_target_group" "sfs-target-group" {
  name     = "${var.resource-prefix}-sfs-target-group"
  port     = 8094
  protocol = "TCP"
  vpc_id   = "${var.vpc-id}"
  stickiness = []
}

resource "aws_alb_listener" "sfs-nlb-listener" {
  load_balancer_arn = "${var.internal-nlb-arn}"
  port              = "8094"
  protocol          = "TCP"

  default_action {
    target_group_arn = "${aws_alb_target_group.sfs-target-group.arn}"
    type             = "forward"
  }
}

resource "aws_alb_target_group" "router-target-group" {
  name     = "${var.resource-prefix}-router-target-group"
  port     = 8095
  protocol = "TCP"
  vpc_id   = "${var.vpc-id}"
  stickiness = []
}

resource "aws_alb_listener" "router-nlb-listener" {
  load_balancer_arn = "${var.internal-nlb-arn}"
  port              = "8095"
  protocol          = "TCP"

  default_action {
    target_group_arn = "${aws_alb_target_group.router-target-group.arn}"
    type             = "forward"
  }
}