variable "folder_id" {
  type        = string
  default     = "b1gul1ta5kjgetdeqi9e"
  description = "Идентификатор каталога"
}

variable "zone1" {
  type        = string
  default     = "ru-central1-a"
  description = "Зона для первой сети"
}

variable "zone2" {
  type        = string
  default     = "ru-central1-b"
  description = "Зона для втрой сети"
}

variable "zone3" {
  type        = string
  default     = "ru-central1-a"
  description = "Зона для третьей сети"
}

variable "cidr_1" {
  type        = string
  default     = "10.1.0.0/16"
  description = "CIDR для VPC 1"
}

variable "cidr_2" {
  type        = string
  default     = "10.2.0.0/16"
  description = "CIDR для VPC 2"
}

variable "cidr_3" {
  type        = string
  default     = "10.3.0.0/16"
  description = "CIDR для VPC 3"
}
