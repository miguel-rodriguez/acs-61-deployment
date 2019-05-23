output "alb-name" {
  value = "${aws_alb.alb.name}"
}
output "alb-dns" {
  value = "${aws_alb.alb.dns_name}"
}
output "alb-security-group-id" {
  value = "${aws_security_group.alb-sg.id}"
}
output "alb-arn" {
  value = "${aws_alb.alb.arn}"
}
output "alb-listener-arn" {
  value = "${aws_alb_listener.alb-listener.arn}"
}