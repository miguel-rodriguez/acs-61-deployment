locals {
  id = "${replace(var.name, " ", "-")}"
}

# ----------------------------------------
# CREATE AND MOUNT EFS
# ----------------------------------------
resource "aws_efs_file_system" "efs" {
  creation_token = "${local.id}"
  tags = "${merge(var.tags, map("Name", var.name))}"
  encrypted = true
}

# Security group EFS access
resource "aws_security_group" "efs" {
  name = "${local.id}-EFS"
  description = "Access to ports EFS (2049)"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port = 2049
    to_port = 2049
    protocol = "tcp"
    security_groups = ["${var.access_sg_ids}"]
    description = "Open to incoming EFS traffic from App instances"
  }

  ingress {
    from_port = 111
    to_port = 111
    protocol = "tcp"
    security_groups = ["${var.access_sg_ids}"]
    description = "Open to incoming EFS traffic from App instances"
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Open to all outgoing traffic"
  }

  tags = "${merge(var.tags, map("Name", "${var.name} EFS"))}"
}

#Terraform Does not support an array for "subnet_id" by now create 3 targets should be used instead.
resource "aws_efs_mount_target" "efs-subnets" {
  count = 2
  subnet_id = "${element(var.subnets, count.index)}"
  file_system_id = "${aws_efs_file_system.efs.id}"  
  security_groups = ["${var.security_group_id}"]
}
