terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.123.0"
}

resource "random_id" "bucket_id" {
  byte_length = 4
}

resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = var.s3scc_id
  description        = "static access key for object storage"
}

resource "yandex_storage_bucket" "s3-storage" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key

  bucket = "${var.bucket_name}"
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

resource "yandex_storage_object" "site-index" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = yandex_storage_bucket.s3-storage.bucket
  key        = "index.html"
  source     = "./public/index.html"
}

resource "yandex_storage_object" "site-source" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = yandex_storage_bucket.s3-storage.bucket
  key        = var.js_file
  source     = "./public/${var.js_file}"
}

resource "yandex_storage_object" "config-json" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = yandex_storage_bucket.s3-storage.bucket
  key        = "config.js"
  content     = "window.REST_APP_ID='${var.api_id}';"
}