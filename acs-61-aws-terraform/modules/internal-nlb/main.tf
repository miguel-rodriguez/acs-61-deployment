### Load balancer ###
resource "aws_security_group" "internal-nlb-sg" {
  name = "${var.resource-prefix}-internal-nlb-sg"
  description = "Internal ALB security group"
  vpc_id = "${var.vpc-id}"

  ingress {
    from_port = "8983"
    to_port = "8983"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = "8090"
    to_port = "8095"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.resource-prefix}-alb-sg"
  }
}

resource "aws_alb" "internal-nlb" {
  name = "${var.resource-prefix}-internal-nlb"
  internal = true
  subnets = ["${var.public-subnet-1-id}", "${var.public-subnet-2-id}"]
  load_balancer_type = "network"

  tags {
    Name = "${var.resource-prefix}-internal-nlb"
  }
}
