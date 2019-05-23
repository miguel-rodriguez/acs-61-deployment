output "internal-nlb-name" {
  value = "${aws_alb.internal-nlb.name}"
}
output "internal-nlb-dns" {
  value = "${aws_alb.internal-nlb.dns_name}"
}
output "internal-nlb-security-group-id" {
  value = "${aws_security_group.internal-nlb-sg.id}"
}
output "internal-nlb-arn" {
  value = "${aws_alb.internal-nlb.arn}"
}