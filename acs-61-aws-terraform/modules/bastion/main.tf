### Bastion node ###
resource "aws_instance" "bastion" {
  ami = "${var.bastion-image-id}"
  instance_type = "t2.nano"
  key_name = "${var.autoscaling-group-key-name}"

  vpc_security_group_ids = ["${aws_security_group.bastion-sg.id}"]

  subnet_id = "${var.public-subnet-1-id}"

  tags = {
    Name = "${var.resource-prefix}-bastion"
  }
}

### Security group fro bastion node ###
resource "aws_security_group" "bastion-sg" {
  name = "${var.resource-prefix}-bastion"
  description = "Bastion security group"
  vpc_id = "${var.vpc-id}"

  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
      from_port = 0
      to_port = 0
      protocol = -1
      cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.resource-prefix}-bastion-sg"
  }
}

