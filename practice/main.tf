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
  cloud_id  = local.config.core.cloud_id
  zone      = local.config.core.zone

  k8s_instances_count   = local.config.k8s.instances_count
  k8s_instance_platform = local.config.k8s.instance_platform

  public_s3_name = local.config.s3.public_s3_name
  configurations_s3 = local.config.s3.configurations_s3_name
  js_file        = local.config.public.js
}

module "accounts" {
  source    = "./modules/account"
  folder_id = local.folder_id
}

module "static" {
  source      = "./modules/static"
  folder_id   = local.folder_id
  bucket_name = local.public_s3_name
  s3scc_id    = module.accounts.s3_sa_id
  js_file     = local.js_file
}

module "configurations" {
  source      = "./modules/configurations"
  folder_id   = local.folder_id
  bucket_name = local.configurations_s3
  s3scc_id    = module.accounts.s3_sa_id
}

output "creator-site" {
  value = "Сайт: https://website.yandexcloud.net/${local.public_s3_name}"
}

output "s3fs-auth" {
  value = nonsensitive("Для монтирования конфига выполните: echo ${module.configurations.access_key}:${module.configurations.secret_key} > ~/.passwd-s3fs && chmod 600 ~/.passwd-s3fs")
}