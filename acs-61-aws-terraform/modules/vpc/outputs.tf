output "vpc-id" {
  value = "${aws_vpc.vpc.id}"
}
output "vpc-default-sg-id" {
  value = "${aws_vpc.vpc.default_security_group_id}"
}
output "private-subnet-1-id" {
  value = "${aws_subnet.private-subnet-1.id}"
}
output "private-subnet-2-id" {
  value = "${aws_subnet.private-subnet-2.id}"
}
output "public-subnet-1-id" {
  value = "${aws_subnet.public-subnet-1.id}"
}
output "public-subnet-2-id" {
  value = "${aws_subnet.public-subnet-2.id}"
}

