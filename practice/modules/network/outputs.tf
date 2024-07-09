output "creator_vpc_id" {
  description = "Creator VPC Id "
  value       = yandex_vpc_subnet.creator_vpc.id
}

output "net_id" {
  description = "Company Network Id"
  value       = yandex_vpc_network.net.0.id
}