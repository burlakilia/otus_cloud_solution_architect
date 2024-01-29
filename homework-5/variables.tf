variable "folder_id" {
  type        = string
  default     = "b1gul1ta5kjgetdeqi9e"
  description = "Идентификатор каталога"
}

variable "pg_user" {
  type        = string
  default     = "homework5"
  description = "Пользователь PG"
}

variable "pg_user_pwd" {
  type        = string
  default     = "homework5"
  description = "Пароль для пользователя PG"
}

variable "mdb_proxy_id" {
  type        = string
  default     = "akflaceofdeaaddd4k4b"
  description = "Идентификатор созданой руками прокси mdb"
}

variable "mdb_proxy_endpoint" {
  type        = string
  default     = "akflaceofdeaaddd4k4b.postgresql-proxy.serverless.yandexcloud.net:6432"
  description = "Точка входа созданой руками прокси mdb"
}

variable "yandex_whether_api_token" {
  type      = string
  default   = "56c03c8d-1db8-4525-b756-214007bcd4ad"
  description = "Ключ от апи погоды"
}