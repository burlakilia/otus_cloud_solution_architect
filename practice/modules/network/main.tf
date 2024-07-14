terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.123.0"
}

resource "yandex_vpc_network" "net" {
  count       = 1
  name        = var.network_name
  description = var.network_desc
  folder_id   = var.folder_id
}

resource "yandex_vpc_subnet" "creator_vpc" {
  name           = "creator"
  description    = "Зона для компонента Creator"
  network_id     = yandex_vpc_network.net[0].id
  v4_cidr_blocks = [var.cidr]
  zone           = var.zone
}


resource "yandex_vpc_subnet" "vpc_k8s" {
  name           = "k8s-zone"
  description    = "Зона для k8s"
  network_id     = yandex_vpc_network.net[0].id
  v4_cidr_blocks = [var.cidr_k8s]
  zone           = var.zone
}

resource "yandex_vpc_security_group" "regional-k8s-sg" {
  name        = "regional-k8s-sg"
  description = "Групповые правила для k8s сети."
  network_id  = yandex_vpc_network.net[0].id

  ingress {
    description    = "The rule allows availability checks from the load balancer's range of addresses. It is required for the operation of a fault-tolerant cluster and load balancer services."
    protocol       = "TCP"
    v4_cidr_blocks = ["198.18.235.0/24", "198.18.248.0/24"] # The load balancer's address range
    from_port      = 0
    to_port        = 65535
  }

  ingress {
    description       = "The rule allows the master-node and node-node interaction within the security group"
    protocol          = "ANY"
    predefined_target = "self_security_group"
    from_port         = 0
    to_port           = 65535
  }

  ingress {
    description    = "The rule allows the pod-pod and service-service interaction. Specify the subnets of your cluster and services."
    protocol       = "ANY"
    v4_cidr_blocks = [var.cidr]
    from_port      = 0
    to_port        = 65535
  }

  ingress {
    description    = "The rule allows receipt of debugging ICMP packets from internal subnets"
    protocol       = "ICMP"
    v4_cidr_blocks = [var.cidr]
  }

  ingress {
    description    = "The rule allows connection to Kubernetes API on 6443 port from specified network"
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 6443
  }

  ingress {
    description    = "The rule allows connection to Kubernetes API on 443 port from specified network"
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }

  egress {
    description    = "The rule allows all outgoing traffic. Nodes can connect to Yandex Container Registry, Object Storage, Docker Hub, and more."
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}