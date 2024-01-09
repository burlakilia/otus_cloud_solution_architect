terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

locals {
  folder_id = var.folder_id
}

resource "yandex_function_iam_binding" "function-iam" {
  function_id = yandex_function.bff_function.id
  role        = "functions.functionInvoker"
  members = [
    "serviceAccount:${yandex_iam_service_account.sa.id}",
  ]
}

resource "yandex_function_iam_binding" "function-iam-service" {
  function_id = yandex_function.back_service_1.id
  role        = "functions.functionInvoker"
  members = [
    "serviceAccount:${yandex_iam_service_account.sa.id}",
  ]
}


resource "yandex_iam_service_account" "sa" {
  folder_id = local.folder_id
  name      = "s3-sa"
}

resource "yandex_vpc_network" "net" {
  description = "Виртуальная сеть кампании"
  count = 1
  name = "Private VPC"
  folder_id = var.folder_id
}

resource "yandex_vpc_subnet" "vpc_public" {
  name = "Public Zone"
  description = "Зона в которой распологаются публичные сервисы"
  network_id     = yandex_vpc_network.net[0].id
  v4_cidr_blocks = [var.cidr_public]
  zone           = var.public_zone
}

resource "yandex_vpc_subnet" "vpc_private" {
  name = "Private Zone"
  description = "Правитная зона для дб и сервисов"
  network_id     = yandex_vpc_network.net[0].id
  v4_cidr_blocks = [var.cidr_private]
  zone           = var.private_zone
}

resource "yandex_mdb_redis_cluster" "redis-db" {
  name        = "redis"
  environment = "PRESTABLE"
  network_id  = yandex_vpc_network.net[0].id

  config {
    password = "test1234"
    version  = "6.2"
  }

  resources {
    resource_preset_id = "hm1.nano"
    disk_size          = 16
  }

  host {
    zone      = var.private_zone
    subnet_id = yandex_vpc_subnet.vpc_private.id
  }

  maintenance_window {
    type = "ANYTIME"
  }
}

resource "yandex_function" "bff_function" {
  name               = "bff"
  description        = "Bff public function"
  user_hash          = "bff"
  runtime            = "nodejs18"
  entrypoint         = "bff/index.handler"
  memory             = "128"
  execution_timeout  = "10"
  service_account_id = yandex_iam_service_account.sa.id
  tags               = ["bff_function", "latest", "test"]

  environment = {
    SERVICE_NAME = yandex_function.back_service_1.id
  }

  content {
    zip_filename = "./src/bff.zip"
  }
}

resource "yandex_function" "back_service_1" {
  name               = "service-function"
  description        = "Private Service function"
  user_hash          = "service"
  runtime            = "nodejs18"
  entrypoint         = "index.handler"
  memory             = "128"
  execution_timeout  = "10"
  service_account_id = yandex_iam_service_account.sa.id
  tags               = ["service", "latest"]

  environment = {
    REDIS_HOST = yandex_mdb_redis_cluster.redis-db.host[0].fqdn
    REDIS_PWD = yandex_mdb_redis_cluster.redis-db.config[0].password
    REDIS_USER =  yandex_mdb_redis_cluster.redis-db.name
  }

  connectivity {
    network_id = yandex_vpc_network.net[0].id
  }

  content {
    zip_filename = "./src/service.zip"
  }

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
      title: "Test API"
    paths:
      /hello:
        get:
          summary: Say hello
          operationId: hello
          parameters:
            - name: user
              in: query
              description: User name to appear in greetings
              required: false
              schema:
                type: string
                default: 'world'
          responses:
            '200':
              description: Greeting
              content:
                'text/plain':
                  schema:
                    type: "string"
          x-yc-apigateway-integration:
            type: cloud_functions
            function_id: "${yandex_function.bff_function.id}"
            service_account_id: "${yandex_iam_service_account.sa.id}"
  EOT
}


output "api_ip" {
  value = yandex_api_gateway.api.id
}