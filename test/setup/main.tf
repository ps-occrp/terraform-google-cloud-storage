/**
 * Copyright 2018 Google LLC
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

module "project" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 18.0"

  name              = "ci-cloud-storage"
  random_project_id = "true"
  org_id            = var.org_id
  folder_id         = var.folder_id
  billing_account   = var.billing_account

  activate_apis = [
    "cloudkms.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "iam.googleapis.com",
    "serviceusage.googleapis.com",
    "storage-api.googleapis.com",
  ]
}

resource "google_folder" "autokey_folder" {
  provider            = google-beta
  display_name        = "ci-cloud-storage-folder"
  parent              = "folders/${var.folder_id}"
  deletion_protection = false
}

resource "google_project" "key_project" {
  provider        = google-beta
  project_id      = "ci-cloud-storage-autokey"
  name            = "ci-cloud-storage-autokey"
  folder_id       = google_folder.autokey_folder.folder_id
  billing_account = var.billing_account
  depends_on      = [google_folder.autokey_folder]
  deletion_policy = "DELETE"
}

resource "google_project_service" "kms_api_service" {
  provider                   = google-beta
  service                    = "cloudkms.googleapis.com"
  project                    = google_project.key_project.project_id
  disable_on_destroy         = false
  disable_dependent_services = true
  depends_on                 = [google_project.key_project]
}

resource "time_sleep" "wait_enable_service_api" {
  depends_on      = [google_project_service.kms_api_service]
  create_duration = "30s"
}

resource "google_project_service_identity" "kms_service_agent" {
  provider   = google-beta
  service    = "cloudkms.googleapis.com"
  project    = google_project.key_project.number
  depends_on = [time_sleep.wait_enable_service_api]
}

resource "time_sleep" "wait_service_agent" {
  depends_on      = [google_project_service_identity.kms_service_agent]
  create_duration = "10s"
}

resource "google_project_iam_member" "autokey_project_admin" {
  provider   = google-beta
  project    = google_project.key_project.project_id
  role       = "roles/cloudkms.admin"
  member     = "serviceAccount:service-${google_project.key_project.number}@gcp-sa-cloudkms.iam.gserviceaccount.com"
  depends_on = [time_sleep.wait_service_agent]
}

resource "time_sleep" "wait_srv_acc_permissions" {
  create_duration = "10s"
  depends_on      = [google_project_iam_member.autokey_project_admin]
}

resource "google_kms_autokey_config" "autokey_config" {
  provider    = google-beta
  folder      = google_folder.autokey_folder.folder_id
  key_project = "projects/${google_project.key_project.project_id}"
  depends_on  = [time_sleep.wait_srv_acc_permissions]
}

resource "time_sleep" "wait_autokey_config" {
  create_duration = "10s"
  depends_on      = [google_kms_autokey_config.autokey_config]
}
