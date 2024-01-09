variable "folder_id" {
  type        = string
  default     = "b1gul1ta5kjgetdeqi9e"
  description = "Идентификатор каталога"
}

variable "cloud_id" {
  type = string
  default = "b1gv3dsnao2129c3djdj"
  description = "Идентификатор облака"
}

variable "public_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "Зона для публичной сети"
}

variable "private_zone" {
  type        = string
  default     = "ru-central1-b"
  description = "Зона для приватных сервисов компании"
}

variable "cidr_public" {
  type        = string
  default     = "10.1.0.0/16"
  description = "CIDR для публичных IP"
}

variable "cidr_private" {
  type        = string
  default     = "10.2.0.0/16"
  description = "CIDR для приватной сети"
}

variable "frontend_port" {
  type    = number
  default = 80
}

variable "backend_port" {
  type    = number
  default = 3000
}

variable "db_port" {
  type    = number
  default = 6000
}
