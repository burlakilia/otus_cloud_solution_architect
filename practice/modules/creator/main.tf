terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.123.0"
}

resource "yandex_iam_service_account" "creator-sa" {
  folder_id = var.folder_id
  name      = "creator-service-account"
}

resource "random_string" "jwt_private_key" {
  length      = 24
}

# Creator API Serverless
resource "yandex_function" "creator-auth" {
  name               = "creator-auth"
  description        = "Сервис отвечает за авторизацию пользователя"
  user_hash          = "service"
  runtime            = "nodejs18"
  entrypoint         = "index.handler"
  memory             = "128"
  execution_timeout  = "60"

  service_account_id = yandex_iam_service_account.creator-sa.id
  tags               = ["creator", "auth"]

  environment = {
    JWT_PRIVATE_KEY: random_string.jwt_private_key.result
    USER_LOGIN: var.user_login
    USER_PWD: var.user_pwd
    GITLAB_TOKEN: var.gitlab_token
    GITLAB_HOST: var.gitlab_host
  }

  content {
    zip_filename = "./serverless/creator-auth/creator-auth.zip"
  }
}


# Creator Gitlab Serverless
resource "yandex_function" "creator-gitlab" {
  name               = "creator-gitlab"
  description        = "Сервис отвечает за интеграцию с gitlab"
  user_hash          = "service"
  runtime            = "nodejs18"
  entrypoint         = "index.handler"
  memory             = "128"
  execution_timeout  = "60"

  service_account_id = yandex_iam_service_account.creator-sa.id
  tags               = ["creator", "gitlab"]

  environment = {
    JWT_PRIVATE_KEY: random_string.jwt_private_key.result
  }

  content {
    zip_filename = "./serverless/creator-gitlab/creator-gitlab.zip"
  }
}

resource "yandex_function_iam_binding" "creator-fn-iam" {
  function_id = yandex_function.creator-auth.id
  role        = "functions.functionInvoker"
  members = [
    "serviceAccount:${yandex_iam_service_account.creator-sa.id}",
  ]
}

resource "yandex_function_iam_binding" "creator-gitlab-iam" {
  function_id = yandex_function.creator-gitlab.id
  role        = "functions.functionInvoker"
  members = [
    "serviceAccount:${yandex_iam_service_account.creator-sa.id}",
  ]
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
      title: "Creator API"
    paths:
      /create:
        post:
          summary: CreateProject
          operationId: Create
          responses:
            '200':
              description: New Gitlab Project
              content:
                'text/plain':
                  schema:
                    type: "string"
          x-yc-apigateway-integration:
            type: cloud_functions
            function_id: "${yandex_function.creator-gitlab.id}"
            service_account_id: "${yandex_iam_service_account.creator-sa.id}"
      /auth:
        post:
          summary: AuthUser
          operationId: Auth
          responses:
            '200':
              description: Auth User By Password
              content:
                'text/plain':
                  schema:
                    type: "string"
          x-yc-apigateway-integration:
            type: cloud_functions
            function_id: "${yandex_function.creator-auth.id}"
            service_account_id: "${yandex_iam_service_account.creator-sa.id}"
  EOT
}