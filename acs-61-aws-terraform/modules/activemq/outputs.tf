output "ssl-endpoint-1" {
  value = "${aws_mq_broker.activemq.instances.0.endpoints.0}"
}
output "ssl-endpoint-2" {
  value = "${aws_mq_broker.activemq.instances.1.endpoints.0}"
}