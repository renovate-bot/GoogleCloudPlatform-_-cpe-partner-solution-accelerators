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

# Override DRS - allow from provider project
resource "google_org_policy_policy" "override_drs" {
  parent = "${google_folder.subscr-root.name}"
  name   = "${google_folder.subscr-root.name}/policies/iam.allowedPolicyMemberDomains"

  spec {
    inherit_from_parent = true

    rules {
      values {
        allowed_values = concat(["is:principalSet://iam.googleapis.com/organizations/${var.subscr_vpc_sc_policy_parent_org_id}"], var.subscr_drs_allowlisted_org_ids)
      }
    }
  }
}
