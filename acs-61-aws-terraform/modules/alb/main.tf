### Load balancer ###
resource "aws_security_group" "alb-sg" {
  name = "${var.resource-prefix}-alb-sg"
  description = "ALB security group"
  vpc_id = "${var.vpc-id}"

  ingress {
    from_port = "80"
    to_port = "80"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = "9090"
    to_port = "9090"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = "443"
    to_port = "443"
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

resource "aws_alb" "alb" {
  name = "${var.resource-prefix}-alb"
  internal = false
  security_groups = ["${aws_security_group.alb-sg.id}"]
  subnets = ["${var.public-subnet-1-id}", "${var.public-subnet-2-id}"]

  tags {
    Name = "${var.resource-prefix}-alb"
  }
}

resource "aws_alb_listener" "alb-listener" {
  load_balancer_arn = "${aws_alb.alb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Request Not Found"
      status_code  = "404"
    }
  }
}