output "creator_vpc_id" {
  description = "Creator VPC Id "
  value       = yandex_vpc_subnet.creator_vpc.id
}

output "net_id" {
  description = "Company Network Id"
  value       = yandex_vpc_network.net.0.id
}

output "k8s_sg_id" {
  description = "K8S Security Group id"
  value       = yandex_vpc_security_group.regional-k8s-sg.id
}

output "k8s_vpc_id" {
  description = "K8S vpc id"
  value       = yandex_vpc_subnet.vpc_k8s.id
}