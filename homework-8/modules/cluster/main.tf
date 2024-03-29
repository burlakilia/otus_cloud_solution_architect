terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

resource "yandex_kms_symmetric_key" "kms-key" {
  # A Yandex Key Management Service key for encrypting critical information, including passwords, OAuth tokens, and SSH keys.
  name              = "kms-key"
  default_algorithm = "AES_128"
  rotation_period   = "8760h" # 1 year.
}


resource "yandex_kubernetes_cluster" "k8s" {
  network_id = var.net_id
  master {
    zonal {
      zone      = var.zone
      subnet_id = var.vpc_id
    }
    public_ip          = true
    security_group_ids = [var.sg_id]
  }
  service_account_id      = var.sa_id
  node_service_account_id = var.sa_id
  depends_on = [
    var.editor_role,
    var.puller_role,
  ]
  kms_provider {
    key_id = yandex_kms_symmetric_key.kms-key.id
  }
}

resource "yandex_alb_target_group" "lb_target_group" {
  name = "lbtarget"

  target {
    private_ipv4_address = true
    ip_address           = "10.1.0.5"
  }
}

resource "yandex_lb_network_load_balancer" "internal-lb" {
  name                = "internal-lb"
  type                = "internal"
  deletion_protection = "true"
  listener {
    name        = "k8s-listener"
    port        = 80
    target_port = 81
    protocol    = "tcp"
    internal_address_spec {
      subnet_id  = var.vpc_id
      ip_version = "ipv4"
    }
  }
}

resource "yandex_kubernetes_node_group" "k8s-node-group" {
  description = "Node group for Managed Service for Kubernetes cluster"
  name        = "k8s-group"
  cluster_id  = yandex_kubernetes_cluster.k8s.id
  version     = "1.26"

  scale_policy {
    fixed_scale {
      size = var.instances_count
    }
  }

  allocation_policy {
    location {
      zone = var.zone
    }
  }

  instance_template {
    platform_id = var.instance_platform

    network_interface {
      nat                = true
      subnet_ids         = [var.vpc_id]
      security_group_ids = [var.sg_id]
    }

    resources {
      memory = 4 # RAM quantity in GB
      cores  = 4 # Number of CPU cores
    }

    boot_disk {
      type = "network-hdd"
      size = 64 # Disk size in GB
    }
  }
}
