terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

resource "yandex_iam_service_account" "sa" {
  folder_id = var.folder_id
  name      = "k8s-root-sa"
}

resource "yandex_iam_service_account" "s3acc" {
  folder_id = var.folder_id
  name      = "s3-storage-admin"
}

resource "yandex_resourcemanager_folder_iam_member" "sa-editor" {
  folder_id = var.folder_id
  role      = "storage.admin"
  member    = "serviceAccount:${yandex_iam_service_account.s3acc.id}"
}

resource "yandex_iam_service_account" "ci_cd_acc" {
  folder_id = var.folder_id
  name      = "ci_cd_acc"
}

resource "yandex_resourcemanager_folder_iam_binding" "ci_cd_acc_role" {
  folder_id = var.folder_id
  members = [
    "serviceAccount:${yandex_iam_service_account.ci_cd_acc.id}",
  ]
  role  = "container-registry.images.pusher"
}

resource "yandex_iam_service_account_static_access_key" "ci-cd-static-key" {
  service_account_id = yandex_iam_service_account.ci_cd_acc.id
  description        = "static access key for object storage"
}

resource "yandex_resourcemanager_folder_iam_member" "images-puller" {
  # Сервисному аккаунту назначается роль "container-registry.images.puller".
  folder_id = var.folder_id
  role      = "container-registry.images.pusher"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

resource "yandex_iam_service_account" "sa_pusher" {
  folder_id = var.folder_id
  name      = "registry-pusher"
}

# Сервисному аккаунту назначается роль "container-registry.images.puller".
resource "yandex_resourcemanager_folder_iam_member" "images_puller" {
  folder_id = var.folder_id
  role      = "container-registry.images.puller"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

# Сервисному аккаунту назначается роль "editor".
resource "yandex_resourcemanager_folder_iam_member" "sa_editor" {
  folder_id = var.folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

# Сервисному аккаунту назначается роль "editor".
resource "yandex_resourcemanager_folder_iam_member" "images_pusher" {
  folder_id = var.folder_id
  role      = "container-registry.images.pusher"
  member    = "serviceAccount:${yandex_iam_service_account.sa_pusher.id}"
}