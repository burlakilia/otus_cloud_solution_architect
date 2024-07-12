variable "folder_id" {
  type        = string
  description = "Идентификатор фолдера, для которого создаем сеть"
}

variable "user_login" {
  type        = string
  description = "логин пользователя"
}

variable "user_pwd" {
  type        = string
  description = "пароль пользователя"
}

variable "gitlab_token" {
  type        = string
  description = "токен для доступа в gitlab"
}

variable "gitlab_host" {
  type        = string
  description = "хост gitlab"
}

variable "registry_id" {
  type        = string
  description = "id registry"
}

variable "ci_cd_token" {
  type        = string
  description = "токен для авторизации со стороны ci_cd"
}

variable "s3_access_key" {
  type        = string
  description = "access key для доступа к s3"
}

variable "s3_secret_key" {
  type        = string
  description = "secret для доступа к s3"
}


variable "config_bucket_name" {
  type        = string
  description = "бакет с конфигами"
}