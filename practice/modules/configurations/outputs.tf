output "s3_bucket_id" {
  description = "Id созданого бакета"
  value       = yandex_storage_bucket.s3-storage.id
}

output "secret_key" {
  description = "Secret Key"
  value       = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
}

output "access_key" {
  description = "Access Key"
  value       = yandex_iam_service_account_static_access_key.sa-static-key.access_key
}

output "access_key_id" {
  description = "Access Key Id"
  value       = yandex_iam_service_account_static_access_key.sa-static-key.id
}