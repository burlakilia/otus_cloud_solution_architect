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

variable "registry_id" {
  type = string
  default = "crpt2j0n2kc6tgvnde9b"
  description = "Идентификатор regstry для docker образов"
}

variable "zone" {
  type        = string
  default     = "ru-central1-a"
  description = "Зона для сети"
}

variable "cidr_k8s" {
  type        = string
  default     = "10.1.0.0/16"
  description = "CIDR для приватной сети"
}

variable "logs_id" {
  type      = string
  default   = "e23ekaubt80euqnlhn02"
  description = "Идентификатор груп логов"
}