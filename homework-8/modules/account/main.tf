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