output "efs-end-point" {
  description = "EFS end point"
  value       = "${aws_efs_file_system.efs.dns_name}"
}

output "file_system_id" {
  value = "${aws_efs_file_system.efs.id}"
}

output "dns_name" {
  value = "${aws_efs_file_system.efs.dns_name}"
}

output "mount_target_ids" {
  value = "${join(",", aws_efs_mount_target.efs-subnets.*.id)}"
}

output "mount_target_interface_ids" {
  value = "${join(",", aws_efs_mount_target.efs-subnets.*.network_interface_id)}"
}

output "security_group_id" {
  value = "${aws_security_group.efs.id}"
}