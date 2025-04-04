/**
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

output "bucket" {
  description = "The created storage bucket"
  value       = google_storage_bucket.bucket
}

output "name" {
  description = "Bucket name."
  value       = google_storage_bucket.bucket.name
}

output "url" {
  description = "Bucket URL."
  value       = google_storage_bucket.bucket.url
}

output "internal_kms_configuration" {
  description = "The intenal KMS Resource."
  value       = var.internal_encryption_config.create_encryption_key ? var.internal_encryption_config.use_autokey ? google_kms_key_handle.default[0] : module.encryption_key[0] : null
}

output "apphub_service_uri" {
  value = {
    service_uri = "//storage.googleapis.com/${element(split("//", google_storage_bucket.bucket.url), 1)}"
    service_id  = substr(google_storage_bucket.bucket.name, 0, 63)
    location    = var.location
  }
  description = "URI in CAIS style to be used by Apphub."
}
