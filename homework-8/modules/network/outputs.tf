output "k8s_vpc_id" {
  description = "K8S vpc id"
  value       = yandex_vpc_subnet.vpc_k8s.id
}

output "k8s_sg_id" {
  description = "K8S Security Group id"
  value       = yandex_vpc_security_group.regional-k8s-sg.id
}

output "k8s_net_id" {
  description = "K8S Network id"
  value       = yandex_vpc_network.net.0.id
}