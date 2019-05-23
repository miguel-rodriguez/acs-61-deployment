output "rds-endpoint" {
  value = "${aws_db_instance.db.endpoint}"
}
