output "k8s_sa_id" {
  description = "K8S Service Account Id"
  value       = yandex_iam_service_account.sa.id
}

output "s3_sa_id" {
  description = "S3 Service Account Id"
  value       = yandex_iam_service_account.s3acc.id
}

output "ci_cd_id" {
  description = "Аккаунт для интеграции с CI/CD"
  value       = yandex_iam_service_account.ci_cd_acc.id
}

output "ci_cd_token" {
  description = "Токен для авторизации ci_cd ролью"
  value       = yandex_iam_service_account_static_access_key.ci-cd-static-key.access_key
}

output "k8s_sa_editor_role" {
  description = "Роль редактора, которая привязана к сервисному аккаунту"
  value       = yandex_resourcemanager_folder_iam_member.sa_editor.id
}

output "k8s_sa_images_puller_role" {
  description = "Роль дающая право выкачивать образа"
  value       = yandex_resourcemanager_folder_iam_member.images_puller.id
}

output "k8s_sa_images_pusher_account" {
  description = "Имя аккаунта для push образов в registry"
  value       = yandex_iam_service_account.sa_pusher.name
}