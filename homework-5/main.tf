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

resource "yandex_iam_service_account" "sa" {
  folder_id = local.folder_id
  name      = "s3-sa"
}

resource "yandex_vpc_network" "net" {
  description = "Виртуальная сеть кампании"
  name = "Private VPC"
  folder_id = var.folder_id
}

resource "yandex_vpc_subnet" "private" {
  name           = "private_subnet"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.net.id
  v4_cidr_blocks = ["10.5.0.0/24"]
}

resource "yandex_vpc_security_group" "db-sg" {
  name       = "pgsql-sg"
  network_id = yandex_vpc_network.net.id

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
  network_id          = yandex_vpc_network.net.id
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
    name      = "homework5-pg"
    subnet_id = yandex_vpc_subnet.private.id
  }
  database {
    name  = "homework5"
    owner = var.pg_user
  }
  user {
    name     = var.pg_user
    password = var.pg_user_pwd
  }
}

resource "yandex_function" "context_fn" {
  name               = "context-fn"
  description        = "Function 1: weather context"
  user_hash          = "service"
  runtime            = "nodejs18"
  entrypoint         = "index.handler"
  memory             = "128"
  execution_timeout  = "60"
  service_account_id = yandex_iam_service_account.sa.id
  tags               = ["service", "latest", "context"]

  environment = {
    PROXY_MDB_ENDPOINT = var.mdb_proxy_endpoint
    PROXY_MDB_ID = var.mdb_proxy_id
    PG_USER = yandex_mdb_postgresql_cluster.homework5-pg.user[0].name
    PG_PWD = yandex_mdb_postgresql_cluster.homework5-pg.user[0].password
    FORECAST_FN = yandex_function.forecast_fn.id
  }

  content {
    zip_filename = "./serverless/context/context.zip"
  }

}

resource "yandex_function" "forecast_fn" {
  name               = "forecast-fn"
  description        = "Function 2: weather forecast"
  user_hash          = "service"
  runtime            = "nodejs18"
  entrypoint         = "index.handler"
  memory             = "128"
  execution_timeout  = "60"
  service_account_id = yandex_iam_service_account.sa.id
  tags               = ["service", "latest", "context"]

  environment = {
    API_TOKEN: var.yandex_whether_api_token
  }

  content {
    zip_filename = "./serverless/forecast/forecast.zip"
  }

}

resource "yandex_function_iam_binding" "forecast-fn-iam" {
  function_id = yandex_function.forecast_fn.id
  role        = "functions.functionInvoker"
  members = [
    "serviceAccount:${yandex_iam_service_account.sa.id}",
  ]
}

resource "yandex_function_iam_binding" "context-fn-iam" {
  function_id = yandex_function.context_fn.id
  role        = "functions.functionInvoker"
  members = [
    "serviceAccount:${yandex_iam_service_account.sa.id}",
  ]
}

resource "yandex_resourcemanager_folder_iam_member" "context-fn-db-iam" {
  folder_id   = var.folder_id
  role        = "serverless.mdbProxies.user"
  member      = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

resource "yandex_api_gateway" "api" {
  name = "public-api"
  description = "public api"

  labels = {
    label = "gateway"
  }

  spec = <<-EOT
    openapi: "3.0.0"
    info:
      version: 1.0.0
      title: "Wheather API"
    paths:
      /whether:
        get:
          summary: Get Whether by GeoIP
          operationId: Whether
          responses:
            '200':
              description: Current Whether
              content:
                'text/plain':
                  schema:
                    type: "string"
          x-yc-apigateway-integration:
            type: cloud_functions
            function_id: "${yandex_function.context_fn.id}"
            service_account_id: "${yandex_iam_service_account.sa.id}"
  EOT
}

output "api_ip" {
  value = yandex_api_gateway.api.id
}
