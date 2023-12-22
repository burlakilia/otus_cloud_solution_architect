terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

locals {
  folder_id = var.folder_id
}

resource "yandex_iam_service_account" "sa" {
  folder_id = local.folder_id
  name      = "s3-sa"
}

resource "yandex_vpc_network" "net" {
  description = "Виртуальная сеть кампании"
  count = 1
  name = "Private VPC"
  folder_id = var.folder_id
}

resource "yandex_vpc_subnet" "vpc_1" {
  name = "VPC 1"
  description = "Связана с VPC 3, но не связана с VPC 2"
  network_id     = yandex_vpc_network.net[0].id
  v4_cidr_blocks = [var.cidr_1]
  zone           = var.zone1
}

resource "yandex_vpc_subnet" "vpc_2" {
  name = "VPC 2"
  description = "Связана с VPC 2, но не связана с VPC 1"
  network_id     = yandex_vpc_network.net[0].id
  v4_cidr_blocks = [var.cidr_2]
  zone           = var.zone2
}

resource "yandex_vpc_subnet" "vpc_3" {
  name = "VPC 3"
  description = "Связана с VPC 2 и с VPC 1"
  network_id     = yandex_vpc_network.net[0].id
  v4_cidr_blocks = [var.cidr_3]
  zone           = var.zone3
}

resource "yandex_vpc_security_group" "ssh" {
  network_id = yandex_vpc_network.net[0].id

  ingress {
    description       = "Allow any traffic within the security group"
    protocol          = "TCP"
    from_port         = 22
    to_port           = 22
    v4_cidr_blocks    =  ["0.0.0.0/0"]
  }

  egress {
    description       = "Allow any traffic within the security group"
    protocol          = "TCP"
    from_port         = 22
    to_port           = 22
    v4_cidr_blocks    =  ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "sg_31" {
  name       = "Разрешаем доступ VPC_3 к VPC_1"
  network_id =  yandex_vpc_network.net[0].id

  ingress {
    description       = "Allow any traffic within the security group"
    protocol          = "ANY"
    from_port         = 0
    to_port           = 65535
    v4_cidr_blocks    =  [var.cidr_3, var.cidr_1]
  }

  egress {
    description       = "Allow any traffic within the security group"
    protocol          = "ANY"
    from_port         = 0
    to_port           = 65535
    v4_cidr_blocks    =  [var.cidr_3, var.cidr_1]
  }
}

resource "yandex_vpc_security_group" "sg_32" {
  name       = "Разрешаем доступ VPC_3 к VPC_2"
  network_id =  yandex_vpc_network.net[0].id

  ingress {
    description       = "Allow any traffic within the security group"
    protocol          = "ANY"
    from_port         = 0
    to_port           = 65535
    v4_cidr_blocks    =  [var.cidr_3, var.cidr_2]
  }

  egress {
    description       = "Allow any traffic within the security group"
    protocol          = "ANY"
    from_port         = 0
    to_port           = 65535
    v4_cidr_blocks    =  [var.cidr_3, var.cidr_2]
  }
}

data "yandex_compute_image" "container-optimized-image" {
  family = "container-optimized-image"
}

resource "yandex_compute_instance" "inst3" {
  name        = "inst3"
  zone        = var.zone3

  service_account_id = yandex_iam_service_account.sa.id

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.container-optimized-image.id
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.vpc_3.id
    nat = true
    security_group_ids=[
      yandex_vpc_security_group.sg_31.id,
      yandex_vpc_security_group.sg_32.id,
      yandex_vpc_security_group.ssh.id,
    ]
  }
  resources {
    cores = 2
    memory = 2
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    serial-port-enable = 1
  }
}

resource "yandex_compute_instance" "inst1" {
  name        = "inst1"
  zone        = var.zone1

  service_account_id = yandex_iam_service_account.sa.id

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.container-optimized-image.id
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.vpc_1.id
    nat = true
    security_group_ids=[
      yandex_vpc_security_group.ssh.id,
      yandex_vpc_security_group.sg_31.id,
    ]
  }
  resources {
    cores = 2
    memory = 2
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    serial-port-enable = 1
  }
}

resource "yandex_compute_instance" "inst2" {
  name        = "inst2"
  zone        = var.zone2

  service_account_id = yandex_iam_service_account.sa.id

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.container-optimized-image.id
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.vpc_2.id
    nat = true
    security_group_ids=[
      yandex_vpc_security_group.ssh.id,
      yandex_vpc_security_group.sg_32.id,
    ]
  }
  resources {
    cores = 2
    memory = 2
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    serial-port-enable = 1
  }
}

output "inst1_external_ip" {
  value = yandex_compute_instance.inst1.network_interface.0.nat_ip_address
}

output "inst2_external_ip" {
  value = yandex_compute_instance.inst2.network_interface.0.nat_ip_address
}

output "inst3_external_ip" {
  value = yandex_compute_instance.inst3.network_interface.0.nat_ip_address
}

