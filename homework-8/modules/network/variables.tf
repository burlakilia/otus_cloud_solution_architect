variable "zone" {
  type        = string
  description = "Зона в которой будет развернута к8с сеть"
}

variable "folder_id" {
  type        = string
  description = "Идентификатор фолдера, для которого создаем сеть"
}

variable "network_name" {
  type        = string
  description = "Имя сети"
}

variable "network_desc" {
  type        = string
  description = "Описание сети"
}

variable "cidr_k8s" {
  type        = string
  default     = "10.1.0.0/16"
  description = "CIDR для приватной сети"
}