### URLs to be applied to alfresco-global.properties
locals {
  lb_url = "${var.alb-dns}"
  internal_lb_url = "${var.internal-nlb-dns}"
  db_url = "jdbc:mysql:\\/\\/${var.rds-endpoint}\\/${var.rds-name}?useUnicode=yes\\&characterEncoding=UTF-8\\&useSSL=false"
  mq_user = "${var.mq-user}"
  mq_password = "${var.mq-password}"
  mq_failover = "failover:(${var.mq-ssl-endpoint-1},${var.mq-ssl-endpoint-2})?timeout=30000"
}

### Alfresco with autoscaling ###
resource "aws_security_group" "alfresco-sg" {
  name = "${var.resource-prefix}-repo-sg"
  description = "Alfresco instance security group"
  vpc_id = "${var.vpc-id}"

  ingress {
    from_port = "8080"
    to_port = "8080"
    protocol = "tcp"
    security_groups = ["${var.alb-sg-id}"]
    description = "Alfresco"
  }

  ingress {
    from_port = "22"
    to_port = "22"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH"
  }

  ingress {
    from_port = "5701"
    to_port = "5701"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Alfresco Hazelcast"
  }

  ingress {
    from_port = "61617"
    to_port = "61617"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "AmazonMQ"
  }
  
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.resource-prefix}-alfresco-sg"
  }
}

# Launch configuration #
resource "aws_launch_configuration" "repo-lcfg" {
  name = "${var.resource-prefix}-repo-lcfg"
  image_id = "${var.autoscaling-group-image-id}"
  instance_type = "${var.autoscaling-group-instance-type}"
  iam_instance_profile = "${aws_iam_instance_profile.alfresco-repo-profile.id}"
  key_name = "${var.autoscaling-group-key-name}"
  security_groups = ["${aws_security_group.alfresco-sg.id}"]

  # Create ebs volumes caching content store
  ebs_block_device {
    device_name           = "/dev/xvdb"
    volume_type           = "gp2"
    volume_size           = "${var.cachedcontent-ebs-volume-size}"
    delete_on_termination = true
    encrypted             = true
    iops                  = 0
    snapshot_id           = ""
    no_device             = false
  }

  user_data = <<-EOF
    #!/bin/bash
    ### set alfresco-globla.properties ###
    sudo sed -i 's/MQ-USER/${local.mq_user}/g' /opt/alfresco-content-services/tomcat/shared/classes/alfresco-global.properties
    sudo sed -i 's/MQ-PASSWORD/${local.mq_password}/g' /opt/alfresco-content-services/tomcat/shared/classes/alfresco-global.properties
    sudo sed -i 's|MQ-FAIL-OVER|${local.mq_failover}|g' /opt/alfresco-content-services/tomcat/shared/classes/alfresco-global.properties
    sudo sed -i 's/INTERNAL-LB-URL/${local.internal_lb_url}/g' /opt/alfresco-content-services/tomcat/shared/classes/alfresco-global.properties
    sudo sed -i 's/LB-URL/${local.lb_url}/g' /opt/alfresco-content-services/tomcat/shared/classes/alfresco-global.properties
    sudo sed -i 's/DB-DRIVER/${var.rds-driver}/g' /opt/alfresco-content-services/tomcat/shared/classes/alfresco-global.properties
    sudo sed -i 's/DB-USERNAME/${var.rds-username}/g' /opt/alfresco-content-services/tomcat/shared/classes/alfresco-global.properties
    sudo sed -i 's/DB-PASSWORD/${var.rds-password}/g' /opt/alfresco-content-services/tomcat/shared/classes/alfresco-global.properties
    sudo sed -i 's/DB-NAME/${var.rds-name}/g' /opt/alfresco-content-services/tomcat/shared/classes/alfresco-global.properties
    sudo sed -i 's/DB-URL/${local.db_url}/g' /opt/alfresco-content-services/tomcat/shared/classes/alfresco-global.properties
    sudo sed -i 's/S3-BUCKET-LOCATION/${var.s3-bucket-location}/g' /opt/alfresco-content-services/tomcat/shared/classes/alfresco-global.properties
    sudo sed -i 's/S3-BUCKET-NAME/${var.resource-prefix}-repo-bucket/g' /opt/alfresco-content-services/tomcat/shared/classes/alfresco-global.properties
    sudo sed -i 's/JOD-CONVERTER-PORT/${var.jod-converter-port}/g' /opt/alfresco-content-services/tomcat/shared/classes/alfresco-global.properties
    sudo sed -i 's/PDF-RENDERER-PORT/${var.pdf-renderer-port}/g' /opt/alfresco-content-services/tomcat/shared/classes/alfresco-global.properties
    sudo sed -i 's/IMAGE-MAGICK-PORT/${var.image-magick-port}/g' /opt/alfresco-content-services/tomcat/shared/classes/alfresco-global.properties
    sudo sed -i 's/TIKA-PORT/${var.tika-port}/g' /opt/alfresco-content-services/tomcat/shared/classes/alfresco-global.properties
    sudo sed -i 's/SHARED-FILE-STORE-PORT/${var.shared-file-store-port}/g' /opt/alfresco-content-services/tomcat/shared/classes/alfresco-global.properties
    sudo mkfs -t ext4 /dev/xvdb
    sudo mkdir /opt/alfresco-content-services/alf_data/cachedcontent
    sudo mount /dev/xvdb /opt/alfresco-content-services/alf_data/cachedcontent
    sudo echo "/dev/xvdb       /opt/alfresco-process-services/alf_data/cachedcontent    ext4    defaults,nofail 0 0" >> /etc/fstab
    sudo chown -R alfresco:alfresco /opt/alfresco-content-services/alf_data/cachedcontent
    sudo setenforce 0
    sudo systemctl enable tomcat
    sudo systemctl start tomcat    
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
resource "aws_autoscaling_group" "asg" {
  name = "${var.resource-prefix}-repo-asg"
  launch_configuration = "${aws_launch_configuration.repo-lcfg.id}"
  vpc_zone_identifier = ["${var.private-subnet-1-id}", "${var.private-subnet-2-id}"]
  min_size = "${var.autoscaling-group-min-size}"
  max_size = "${var.autoscaling-group-max-size}"
  desired_capacity = "${var.autoscaling-group-desired-capacity}"
  target_group_arns = ["${aws_alb_target_group.repo-target-group.arn}"]

  tags {
    key = "Name"
    value = "${var.resource-prefix}-alfresco-repo"
    propagate_at_launch = true
  }
}

### Create a role to allow Alfresco to access S3 buckets ###
resource "aws_iam_instance_profile" "alfresco-repo-profile" {
  name = "${var.resource-prefix}-alfresco-repo-instance-profile"
  role = "${aws_iam_role.role.name}"
}

# Role for EC2 instance
resource "aws_iam_role" "role" {
  name = "${var.resource-prefix}-alfresco-repo-s3-role"
  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  }
  EOF
}

# Policy for S3 access
resource "aws_iam_policy" "s3-policy" {
  name        = "${var.resource-prefix}-alfresco-repo-s3-policy"
  description = "S3  policy"

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": ["arn:aws:s3:::${var.resource-prefix}-repo-bucket/*", "arn:aws:s3:::${var.resource-prefix}-code-deploy/*"]
        }
    ]
  }
  EOF
}

# Policy for code deploy
resource "aws_iam_policy" "sqs-sns-policy" {
  name        = "${var.resource-prefix}-alfresco-repo-sqs-sns-policy"
  description = "SQS SNS policy"

  policy = <<-EOF
  {
      "Version": "2012-10-17",
      "Statement": [
          {
              "Effect": "Allow",
              "Resource": "*",
              "Action": [
                  "sqs:SendMessage",
                  "sqs:GetQueueUrl",
                  "sns:Publish"
              ]
          }
      ]
  }
  EOF
}

# Attach policies to role
resource "aws_iam_policy_attachment" "s3-policy-attach" {
  name       = "${var.resource-prefix}-policy-attachment"
  roles      = ["${aws_iam_role.role.name}"]
  policy_arn = "${aws_iam_policy.s3-policy.arn}"
}

resource "aws_iam_policy_attachment" "sqs-sns-policy-attach" {
  name       = "${var.resource-prefix}-policy-attachment"
  roles      = ["${aws_iam_role.role.name}"]
  policy_arn = "${aws_iam_policy.sqs-sns-policy.arn}"
}

### S3 bucket ###
resource "aws_s3_bucket" "alfresco-bucket" {
  bucket = "${var.resource-prefix}-repo-bucket"
  acl    = "private"
  force_destroy = true
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
      }
    }
  }
  tags = {
    Name = "${var.resource-prefix}-alfresco-bucket-s3"
  }
}


# S3 bucket for code deploy applications
resource "aws_s3_bucket" "code-deploy-bucket" {
  bucket = "${var.resource-prefix}-code-deploy"
  acl    = "private"
  force_destroy = true
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
      }
    }
  }

  tags = {
    Name = "${var.resource-prefix}-code-deploy-s3"
  }
}

# Connect ACS up to the Application Load Balancer
resource "aws_alb_target_group" "repo-target-group" {
  name     = "${var.resource-prefix}-repo-target-group"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = "${var.vpc-id}"

  stickiness {    
    type            = "lb_cookie"    
    cookie_duration = 86400    
    enabled         = true
  }

  health_check {
    interval            = 30
    path                = "/alfresco"
    port                = "8080"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    protocol            = "HTTP"
    matcher             = "200,301,302"
  }
}

resource "aws_alb_listener_rule" "alfresco-share-rule" {
  listener_arn = "${var.alb-listener-arn}"
  priority     = 99

  action {
    type = "forward"
    target_group_arn = "${aws_alb_target_group.repo-target-group.arn}"
  }
  condition {
    field  = "path-pattern"
    values = ["/alfresco*"]
  }
}

resource "aws_alb_listener_rule" "acs-share-rule" {
  listener_arn = "${var.alb-listener-arn}"
  priority     = 98

  action {
    type = "forward"
    target_group_arn = "${aws_alb_target_group.repo-target-group.arn}"
  }
  condition {
    field  = "path-pattern"
    values = ["/share*"]
  }
}

resource "aws_alb_listener_rule" "acs-dw-rule" {
  listener_arn = "${var.alb-listener-arn}"
  priority     = 97

  action {
    type = "forward"
    target_group_arn = "${aws_alb_target_group.repo-target-group.arn}"
  }
  condition {
    field  = "path-pattern"
    values = ["/digital-workspace*"]
  }
}

resource "aws_alb_listener_rule" "api-explorer-rule" {
  listener_arn = "${var.alb-listener-arn}"
  priority     = 96

  action {
    type = "forward"
    target_group_arn = "${aws_alb_target_group.repo-target-group.arn}"
  }
  condition {
    field  = "path-pattern"
    values = ["/api-explorer*"]
  }
}