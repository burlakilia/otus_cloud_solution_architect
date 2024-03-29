variable "vpc_id" {
  type        = string
  description = "Идентификатор подсети, где должен быть равзернут кластер"
}

variable "net_id" {
  type        = string
  description = "Идентификатор сети, где будет развернут кластер"
}

variable "zone" {
  type        = string
  description = "Зона кластера"
}

variable "sg_id" {
  type        = string
  description = "Идентификатор сервисной группы"
}

variable "sa_id" {
  type        = string
  description = "Идентификатор сервисного аккаунта"
}

variable "editor_role" {
  type        = string
  description = "Роль редактора"
}

variable "puller_role" {
  type        = string
  description = "Роль пуллера"
}

variable "instances_count" {
  type        = number
  default     = 1
  description = "scale_policy number of hosts"
}

variable "instance_platform" {
  type        = string
  default     = "standard-v2"
  description = "Type of instance of k8s cluster"
}