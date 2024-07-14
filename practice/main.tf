terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.123.0"
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

  public_s3_name    = local.config.s3.public_s3_name
  configurations_s3 = local.config.s3.configurations_s3_name
  js_file           = local.config.public.js

  user_login = local.config.creator.user_login
  user_pwd   = local.config.creator.user_pwd

  gitlab_token = local.config.creator.gitlab_token
  gitlab_host  = local.config.creator.gitlab_host
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
  api_id      = module.creator.api_id
}

module "configurations" {
  source      = "./modules/configurations"
  folder_id   = local.folder_id
  bucket_name = local.configurations_s3
  s3scc_id    = module.accounts.s3_sa_id
}

module "network" {
  source       = "./modules/network"
  zone         = local.zone
  folder_id    = local.folder_id
  network_name = "net"
  network_desc = "Общая сеть решения"
}

module "creator" {
  source             = "./modules/creator"
  user_login         = local.user_login
  user_pwd           = local.user_pwd
  folder_id          = local.folder_id
  gitlab_token       = local.gitlab_token
  gitlab_host        = local.gitlab_host
  registry_id        = module.infra.registry_id
  ci_cd_token        = module.accounts.ci_cd_token
  s3_access_key      = module.configurations.access_key
  s3_secret_key      = module.configurations.secret_key
  config_bucket_name = local.configurations_s3
}

module "infra" {
  source    = "./modules/infra"
  folder_id = local.folder_id

  net_id      = module.network.net_id
  vpc_id      = module.network.k8s_vpc_id
  sg_id       = module.network.k8s_sg_id
  sa_id       = module.accounts.k8s_sa_id
  editor_role = module.accounts.k8s_sa_editor_role
  puller_role = module.accounts.k8s_sa_images_puller_role
  zone        = local.zone
}

output "creator-site" {
  value = "Сайт: https://website.yandexcloud.net/${local.public_s3_name}"
}

output "s3fs-auth" {
  value = nonsensitive("Для монтирования конфига выполните: echo ${module.configurations.access_key}:${module.configurations.secret_key} > ~/.passwd-s3fs && chmod 600 ~/.passwd-s3fs")
}