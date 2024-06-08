terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  zone = "ru-central1-a"
}

locals {
  config = yamldecode(file("config.yaml"))

  folder_id = local.config.core.folder_id
  core_id   = local.config.core.core_id
  zone      = local.config.core.zone

  instances_count   = local.config.k8s.instances_count
  instance_platform = local.config.k8s.instance_platform
}

module "k8s_network" {
  source = "./modules/network"

  folder_id    = local.folder_id
  network_name = "KuberVPC"
  network_desc = "Сеть для кластера кубера"
  zone         = local.zone
}

module "accounts" {
  source    = "./modules/account"
  folder_id = local.folder_id
}

module "k8s_cluster" {
  source = "./modules/cluster"

  net_id      = module.k8s_network.k8s_net_id
  vpc_id      = module.k8s_network.k8s_vpc_id
  sg_id       = module.k8s_network.k8s_sg_id
  zone        = local.zone
  editor_role = module.accounts.k8s_sa_editor_role
  puller_role = module.accounts.k8s_sa_images_puller_role
  sa_id       = module.accounts.k8s_sa_id

  instances_count   = local.instances_count
  instance_platform = local.instance_platform
}

module "s3_bucket" {
  source = "./modules/s3"

  folder_id = local.folder_id
  bucket_name = "test"
  s3scc_id = module.accounts.s3_sa_id
}

resource "yandex_container_registry" "registry" {
  name = "containers-registry"
  folder_id = local.folder_id
  labels = {
    level = "infra"
  }
}

output "token" {
  value = "CLOUD_IAM_TOKEN: ${module.accounts.ci_cd_token}"
}

output "registry" {
  value = "CLOUD_REGISTRY_ID: ${yandex_container_registry.registry.id}"
}