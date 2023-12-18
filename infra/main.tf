terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

locals {
  folder_id = "b1gul1ta5kjgetdeqi9e"
}

resource "random_id" "bucket_id" {
  byte_length = 4
}

provider "yandex" {
  zone = "ru-central1-a"
}

resource "yandex_iam_service_account" "sa" {
  folder_id = local.folder_id
  name      = "s3-sa"
}

resource "yandex_resourcemanager_folder_iam_member" "sa-editor" {
  folder_id = local.folder_id
  role      = "storage.admin"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.sa.id
  description        = "static access key for object storage"
}

resource "yandex_storage_bucket" "free-files" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key

  bucket = "free-files-${random_id.bucket_id.hex}"

  grant {
    type        = "Group"
    permissions = ["READ"]
    uri         = "http://acs.amazonaws.com/groups/global/AuthenticatedUsers"
  }
}

resource "yandex_storage_object" "free-object" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = yandex_storage_bucket.free-files.bucket
  key        = "free.txt"
  source     = "./files/free.txt"

}

resource "yandex_storage_bucket" "paid-files" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key

  bucket = "paid-files-${random_id.bucket_id.hex}"

  grant {
    id          = "ajeh11duqf94qs3n84f3"
    type        = "CanonicalUser"
    permissions = ["READ"]
  }
}

resource "yandex_storage_object" "paid-object" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = yandex_storage_bucket.paid-files.bucket
  key        = "paid.txt"
  source     = "./files/paid.txt"
}