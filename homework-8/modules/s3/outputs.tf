output "s3_bucket_id" {
  description = "Id созданого бакета"
  value       = yandex_storage_bucket.s3-storage.id
}
