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
