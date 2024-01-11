terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  zone = "ru-central1-a"
}

locals {
  folder_id = var.folder_id
}

resource "random_id" "bucket_id" {
  byte_length = 4
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

resource "yandex_storage_bucket" "s3-storage" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key

  bucket = "s3-files-${random_id.bucket_id.hex}"
}

resource "yandex_storage_object" "paid-object" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = yandex_storage_bucket.s3-storage.bucket
  key        = "example.txt"
  source     = "./files/example.txt"
}

resource "yandex_vpc_network" "homework4" {
  name = "homework4"
}

resource "yandex_vpc_subnet" "private" {
  name           = "private_subnet"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.homework4.id
  v4_cidr_blocks = ["10.5.0.0/24"]
}

resource "yandex_vpc_security_group" "pgsql-sg" {
  name       = "pgsql-sg"
  network_id = yandex_vpc_network.homework4.id

  ingress {
    description    = "PostgreSQL"
    port           = 6432
    protocol       = "TCP"
    v4_cidr_blocks = [ "0.0.0.0/0" ]
  }
}

resource "yandex_mdb_postgresql_cluster" "homework4-pg" {
  name                = "homework4-pg"
  environment         = "PRESTABLE"
  network_id          = yandex_vpc_network.homework4.id
  security_group_ids  = [ yandex_vpc_security_group.pgsql-sg.id ]
  deletion_protection = true

  config {
    version = 16
    resources {
      resource_preset_id = "s2.micro"
      disk_type_id       = "network-ssd"
      disk_size          = "20"
    }
  }

  restore {
    backup_id = "c9qofv99340uhd2n6p78:c9qtknt824315ofdovs1"
  }

  host {
    zone      = "ru-central1-a"
    name      = "homework4-pg"
    subnet_id = yandex_vpc_subnet.private.id
  }
  database {
    name  = "homework4"
    owner = var.pg_user
  }
  user {
    name     = var.pg_user
    password = var.pg_user_pwd
  }
}