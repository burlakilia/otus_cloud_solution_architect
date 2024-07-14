terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.123.0"
}


resource "yandex_vpc_security_group" "db-sg" {
  name       = "pgsql-sg"
  network_id = var.net_id

  ingress {
    description    = "Database Security Group"
    port           = 6432
    protocol       = "TCP"
    v4_cidr_blocks = [ "0.0.0.0/0" ]
  }
}

resource "yandex_mdb_postgresql_cluster" "homework5-pg" {
  name                = "homework5-pg"
  environment         = "PRESTABLE"
  network_id          = var.net_id
  security_group_ids  = [ yandex_vpc_security_group.db-sg.id ]
  deletion_protection = false

  config {
    version = 16
    resources {
      resource_preset_id = "s2.micro"
      disk_type_id       = "network-ssd"
      disk_size          = "20"
    }
    access {
      serverless = true
    }
  }

  host {
    zone      = "ru-central1-a"
    name      = "dbs-pg"
    subnet_id = var.vpc_id
  }
  database {
    name  = "practice"
    owner = var.root_user
  }
  user {
    name     = var.root_user
    password = var.root_user_pwd
  }
}