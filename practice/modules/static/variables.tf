variable "folder_id" {
  type        = string
  description = "Идентификатор фолдера, для которого создаем сеть"
}

variable "s3scc_id" {
  type        = string
  description = "Идентификатор сервисного аккунта"
}

variable "bucket_name" {
  type        = string
  description = "Имя бакета, для уникальности добавляется рандомный префикс"
}

variable "js_file" {
  type        = string
  description = "Имя js файла приложения"
}

variable "api_id" {
  type  = string
  description = "Идентификатор api, для запросов"
}