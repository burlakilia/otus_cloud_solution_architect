terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.123.0"
}

resource "yandex_container_registry" "registry" {
  name = "containers-registry"
  folder_id = var.folder_id
  labels = {
    level = "infra"
  }
}
