output "k8s_lb_ext_address_name" {
  description = "Load Balancer Name"
  value       = yandex_lb_network_load_balancer.internal-lb.name
}
