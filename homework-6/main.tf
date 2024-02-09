terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  zone = "ru-central1-a"
}

locals {
  folder_id = var.folder_id
}

resource "yandex_iam_service_account" "sa" {
  folder_id = local.folder_id
  name      = "s3-sa"
}

resource "yandex_resourcemanager_folder_iam_binding" "sa_puller_role" {
  folder_id = local.folder_id
  members = [
    "serviceAccount:${yandex_iam_service_account.sa.id}",
  ]
  role  = "container-registry.images.puller"
}

resource "yandex_resourcemanager_folder_iam_member" "images-puller" {
  # Сервисному аккаунту назначается роль "container-registry.images.puller".
  folder_id = var.folder_id
  role      = "container-registry.images.puller"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "sa_editor" {
  # Сервисному аккаунту назначается роль "editor".
  folder_id = var.folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

resource "yandex_container_registry" "registry" {
  name = "containers-registry"
  folder_id = var.folder_id
  labels = {
    level = "infra"
  }
}

resource "yandex_serverless_container" "serverless_container" {
  name               = "serverless"
  memory             = 128
  service_account_id = yandex_iam_service_account.sa.id
  image {
    url = "cr.yandex/${var.registry_id}/serverless:app"
  }
}

resource "yandex_vpc_network" "net" {
  description = "Виртуальная сеть кампании"
  count = 1
  name = "Private VPC"
  folder_id = var.folder_id
}

data "yandex_compute_image" "container-optimized-image" {
  family = "container-optimized-image"
}

resource "yandex_vpc_subnet" "vpc_k8s" {
  name = "K8S Zone"
  description = "Зона для k8s"
  network_id     = yandex_vpc_network.net[0].id
  v4_cidr_blocks = [var.cidr_k8s]
  zone           = var.zone
}

resource "yandex_compute_instance" "optimized" {
  name        = "optimized"
  zone        = var.zone

  service_account_id = yandex_iam_service_account.sa.id

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.container-optimized-image.id
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.vpc_k8s.id
    nat = true
  }
  resources {
    cores = 2
    memory = 2
  }

  metadata = {
    docker-compose = file("${path.module}/optimized/declaration.yaml")
    user-data = file("${path.module}/optimized/cloud_config.yaml")
  }
}

resource "yandex_vpc_security_group" "regional-k8s-sg" {
  name        = "regional-k8s-sg"
  description = "Group rules enable basic Managed Service for Kubernetes cluster performance. Apply it to the cluster and node groups."
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
    v4_cidr_blocks = [var.cidr_k8s]
    from_port      = 0
    to_port        = 65535
  }

  ingress {
    description    = "The rule allows receipt of debugging ICMP packets from internal subnets"
    protocol       = "ICMP"
    v4_cidr_blocks = [var.cidr_k8s]
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

resource "yandex_kms_symmetric_key" "kms-key" {
  # A Yandex Key Management Service key for encrypting critical information, including passwords, OAuth tokens, and SSH keys.
  name              = "kms-key"
  default_algorithm = "AES_128"
  rotation_period   = "8760h" # 1 year.
}


resource "yandex_kubernetes_cluster" "kuber" {
  network_id = yandex_vpc_network.net[0].id
  master {
    zonal {
      zone      = yandex_vpc_subnet.vpc_k8s.zone
      subnet_id = yandex_vpc_subnet.vpc_k8s.id
    }
    public_ip = true
    security_group_ids = [yandex_vpc_security_group.regional-k8s-sg.id]
  }
  service_account_id      = yandex_iam_service_account.sa.id
  node_service_account_id = yandex_iam_service_account.sa.id
  depends_on = [
    yandex_resourcemanager_folder_iam_member.sa_editor,
    yandex_resourcemanager_folder_iam_member.images-puller
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

resource "yandex_lb_network_load_balancer" "internal-lb-test" {
  name = "internal-lb"
  type = "internal"
  deletion_protection = "true"
  listener {
    name        = "k8s-listener"
    port        = 80
    target_port = 81
    protocol    = "tcp"
    internal_address_spec {
      subnet_id  = yandex_vpc_subnet.vpc_k8s.id
      ip_version = "ipv4"
    }
  }
}

resource "yandex_kubernetes_node_group" "k8s-node-group" {
  description = "Node group for Managed Service for Kubernetes cluster"
  name        = "k8s-group"
  cluster_id  = yandex_kubernetes_cluster.kuber.id
  version     = "1.25"

  scale_policy {
    fixed_scale {
      size = 1 # Number of hosts
    }
  }

  allocation_policy {
    location {
      zone = "ru-central1-a"
    }
  }

  instance_template {
    platform_id = "standard-v2"

    network_interface {
      nat                = true
      subnet_ids         = [yandex_vpc_subnet.vpc_k8s.id]
      security_group_ids = [yandex_vpc_security_group.regional-k8s-sg.id]
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

output "solution_inst_ext_ip" {
  value = yandex_compute_instance.optimized.network_interface.0.nat_ip_address
}