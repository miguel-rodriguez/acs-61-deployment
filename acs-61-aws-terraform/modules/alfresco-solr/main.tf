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
resource "aws_security_group" "alfresco-solr-sg" {
  name = "${var.resource-prefix}-solr-sg"
  description = "Alfresco instance security group"
  vpc_id = "${var.vpc-id}"

  ingress {
    from_port = "8080"
    to_port = "8080"
    protocol = "tcp"
    security_groups = ["${var.alb-sg-id}"]
    description = "Alfresco Tomcat"
  }

  ingress {
    from_port = "61617"
    to_port = "61617"
    protocol = "tcp"
    security_groups = ["${var.vpc-default-sg-id}"]
    description = "AmazonMQ"
  }

  ingress {
    from_port = "9090"
    to_port = "9090"
    protocol = "tcp"
    security_groups = ["${var.alb-sg-id}"]
    description = "Alfresco Zeppelin"
  }

  ingress {
    from_port = "8983"
    to_port = "8983"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Alfresco Solr"
  }

  ingress {
    from_port = "22"
    to_port = "22"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH"
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.resource-prefix}-alfresco-solr-sg"
  }
}

# Launch configuration #
resource "aws_launch_configuration" "solr-lcfg" {
  name = "${var.resource-prefix}-solr-lcfg"
  image_id = "${var.autoscaling-group-image-id}"
  instance_type = "${var.autoscaling-group-instance-type}"
  iam_instance_profile = "${aws_iam_instance_profile.alfresco-solr-profile.id}"
  key_name = "${var.autoscaling-group-key-name}"
  security_groups = ["${aws_security_group.alfresco-solr-sg.id}"]

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
    sudo systemctl enable solr
    sudo systemctl start solr
    sudo systemctl enable zeppelin
    sudo systemctl start zeppelin    
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
resource "aws_autoscaling_group" "solr-asg" {
  name = "${var.resource-prefix}-solr-asg"
  launch_configuration = "${aws_launch_configuration.solr-lcfg.id}"
  vpc_zone_identifier = ["${var.private-subnet-1-id}", "${var.private-subnet-2-id}"]
  min_size = "${var.autoscaling-group-min-size}"
  max_size = "${var.autoscaling-group-max-size}"
  desired_capacity = "${var.autoscaling-group-desired-capacity}"
  target_group_arns = ["${aws_alb_target_group.zeppelin-target-group.arn}", "${aws_alb_target_group.solr-target-group.arn}", "${aws_alb_target_group.solr-ui-target-group.arn}"]

  tags {
    key = "Name"
    value = "${var.resource-prefix}-alfresco-solr"
    propagate_at_launch = true
  }
}

# Connect applications to the Load Balancer
resource "aws_alb_target_group" "zeppelin-target-group" {
  name     = "${var.resource-prefix}-zeppelin-target-group"
  port     = 9090
  protocol = "HTTP"
  vpc_id   = "${var.vpc-id}"

  health_check {
    interval            = 30
    path                = "/zeppelin"
    port                = "9090"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    protocol            = "HTTP"
    matcher             = "200,301,302"
  }  
}

resource "aws_alb_target_group" "solr-target-group" {
  name     = "${var.resource-prefix}-solr-target-group"
  port     = 8983
  protocol = "TCP"
  vpc_id   = "${var.vpc-id}"
  stickiness = []
}

resource "aws_alb_target_group" "solr-ui-target-group" {
  name     = "${var.resource-prefix}-solr-ui-target-group"
  port     = 8983
  protocol = "HTTP"
  vpc_id   = "${var.vpc-id}"

  health_check {
    interval            = 30
    path                = "/solr"
    port                = "8983"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    protocol            = "HTTP"
    matcher             = "200,301,302"
  }  
}

resource "aws_alb_listener_rule" "solr-ui-rule" {
  listener_arn = "${var.alb-listener-arn}"
  priority     = 86

  action {
    type = "forward"
    target_group_arn = "${aws_alb_target_group.solr-ui-target-group.arn}"
  }
  condition {
    field  = "path-pattern"
    values = ["/solr*"]
  }
}

resource "aws_alb_listener_rule" "acs-zeppelin-rule" {
  listener_arn = "${var.alb-listener-arn}"
  priority     = 87

  action {
    type = "forward"
    target_group_arn = "${aws_alb_target_group.zeppelin-target-group.arn}"
  }
  condition {
    field  = "path-pattern"
    values = ["/zeppelin*"]
  }
}

# Define a listener
resource "aws_alb_listener" "solr-nlb-listener" {
  load_balancer_arn = "${var.internal-nlb-arn}"
  port              = "8983"
  protocol          = "TCP"

  default_action {
    target_group_arn = "${aws_alb_target_group.solr-target-group.arn}"
    type             = "forward"
  }
}

### Create a role to allow Alfresco to access S3 buckets ###
resource "aws_iam_instance_profile" "alfresco-solr-profile" {
  name = "${var.resource-prefix}-alfresco-solr-instance-profile"
  role = "${aws_iam_role.role.name}"
}

# Role for EC2 instance
resource "aws_iam_role" "role" {
  name = "${var.resource-prefix}-alfresco-solr-s3-role"
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
  name        = "${var.resource-prefix}-alfresco-solr-s3-policy"
  description = "S3  policy"

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": "*"
        }
    ]
  }
  EOF
}

# Policy for code deploy
resource "aws_iam_policy" "sqs-sns-policy" {
  name        = "${var.resource-prefix}-alfresco-solr-sqs-sns-policy"
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