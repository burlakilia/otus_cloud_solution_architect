variable "zone" {
  type        = string
  description = "Зона в которой будет развернута сеть"
}

variable "folder_id" {
  type        = string
  description = "Идентификатор фолдера, для которого создаем сеть"
}

variable "net_id" {
  type        = string
  description = "ID сети"
}

variable "vpc_id" {
  type        = string
  description = "VPC"
}

variable "root_user" {
  type        = string
  description = "Админ"
}

variable "root_user_pwd" {
  type        = string
  description = "PWD Админа"
}