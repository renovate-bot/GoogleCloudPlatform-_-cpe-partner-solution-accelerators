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

output "project_number_idp" {
  description = "IDP project number"
  value       = module.publ-project-factory[var.prov_project_id_idp].project_number
}
output "project_number_bqds" {
  description = "BQDS project number"
  value       = module.publ-project-bqds.project_number
}
output "folder_id_root" {
  description = "Folder for all related projects"
  value       = google_folder.prov-root.id
}
output "folder_id_core" {
  description = "Folder for provider core projects"
  value       = google_folder.prov-core.id
}
output "folder_id_data" {
  description = "Folder for provider data projects"
  value       = google_folder.prov-data.id
}
output "folder_id_cx" {
  description = "Folder for provider managed (cx) projects"
  value       = google_folder.prov-cx.id
}
