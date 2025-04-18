# Copyright 2024 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     https://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

data "google_secret_manager_secret" "secret-adpwd" {
  secret_id = "secret-adpwd"
}

data "google_secret_manager_secret" "secret-register-computer" {
  secret_id = "secret-register-computer"
}

data "google_secret_manager_secret_version" "secret-adpwd" {
  secret = "secret-adpwd"
}

data "google_secret_manager_secret_version" "secret-register-computer" {
  secret = "secret-register-computer"
}

resource "google_secret_manager_secret_iam_member" "secret-register-computer-regfunc-sa" {
  project = data.google_project.project.project_id
  secret_id = data.google_secret_manager_secret.secret-register-computer.secret_id

  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.regfunc-sa.email}"
}
