output "VPC ID" {
  value = "${module.vpc.vpc-id}"
}

output "RDS Endpoint" {
  value = "${module.rds.rds-endpoint}"
}

output "Alfresco Share" {
  value = "http://${module.alb.alb-dns}/share"
}

output "Alfresco Digital Workspace" {
  value = "http://${module.alb.alb-dns}/digital-workspace"
}
output "Alfresco Zeppelin" {
  value = "http://${module.alb.alb-dns}/zeppelin"
}

output "Alfresco Solr" {
  value = "http://${module.alb.alb-dns}/solr"
}

output "API Explorer" {
  value = "http://${module.alb.alb-dns}/api-explorer"
}