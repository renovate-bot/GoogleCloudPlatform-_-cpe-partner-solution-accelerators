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

locals {
  ingress_policies_bq_perimeter_shared_ds = [
    # Allow off-perimeter internal users (Cloud Console users) in var.publ_vpc_sc_access_level_corp_allowed_identities from the corporate network IP ranges
    # required for the (internal) admins to manage BQ / AH
    {
      "from" = {
        "sources" = {
          access_levels = [ google_access_context_manager_access_level.access_level_allow_corp.title ] # Allow access from corporate network IP ranges
        },
        "identities" = var.publ_vpc_sc_access_level_corp_allowed_identities
        "identity_type" = null
      }
      "to" = {
        "resources" = [
          "*",
#          "projects/${data.google_project.publ_bq_shared_ds.number}",
        ]
        "operations" = {
          "bigquery.googleapis.com" = {
            "methods" = [
              "*",
            ]
          },
          "bigquerydatapolicy.googleapis.com" = {
            "methods" = [
              "*",
            ]
          },
          "datacatalog.googleapis.com" = {
            "methods" = [
              "*",
            ]
          },
        }
      }
    },
    # Allow off-perimeter subscribers (Cloud Console users) from anywhere
    # Public: required for querying columns with policy tags in the public listing (allAuthenticatedUsers or allUsers => subscriber identity not known => ANY_IDENTITY)
    # Private: required for querying columns with policy tags in the private listing (subscriber identity known => gathered upon contracting => in var.publ_vpc_sc_ah_subscriber_identities)
    {
      "from" = {
        "sources" = {
          access_levels = [ google_access_context_manager_access_level.access_level_allow_all.title ] # Allow access from corporate network IP ranges
        },
        "identities" = var.publ_vpc_sc_allow_all_for_public_listing ? [] : var.publ_vpc_sc_ah_subscriber_identities
        "identity_type" = var.publ_vpc_sc_allow_all_for_public_listing ? "ANY_IDENTITY" : null
      }
      "to" = {
        "resources" = [
          "*",
#          "projects/${data.google_project.publ_bq_shared_ds.number}",
        ]
        "operations" = {
          "bigquery.googleapis.com" = {
            "methods" = [
            ]
            "permissions" = [
              "datacatalog.categories.fineGrainedGet"
            ]
          },
          "bigquerydatapolicy.googleapis.com" = {
            "methods" = [
              "*",
            ]
          },
        }
      }
    },
  ]

  egress_policies_bq_perimeter_shared_ds = [
    # Allow egress to ah_exchg,nonvpcsc_ah_exchg (Google Service -> Google Service)
    # required for creating the listings from the dedicated AH projects
    {
      "from" = {
        "identities" = var.publ_vpc_sc_access_level_corp_allowed_identities
      }
      "to" = {
        "resources" = [
          "projects/${data.google_project.publ_ah_exchg.number}",
          "projects/${data.google_project.publ_nonvpcsc_ah_exchg.number}",
        ]
        "operations" = {
          "bigquery.googleapis.com" = {
            "methods" = [
              "*",
            ]
          }
        }
      }
    },
    # Allow egress to bq_src_ds (Google Service -> Google Service)
    # required for creating the view from shared_ds to src_ds
    # NEW: CHAINED VIEWS: required for creating the view from shared_ds to the view in src_ds that is querying the view in fed_ds (so shared_ds -> src_ds -> fed_ds)
    {
      "from" = {
        "identities" = var.publ_vpc_sc_access_level_corp_allowed_identities
      }
      "to" = {
        "resources" = [
          "projects/${data.google_project.publ_bq_src_ds.number}",
          "projects/${data.google_project.publ_bq_fed_ds.number}", # Add fed_ds in addition to src_ds
        ]
        "operations" = {
          "bigquery.googleapis.com" = {
            "methods" = [
              "*",
            ]
          }
        }
      }
    },
    # Allow egress to #subscriber_project_number (Google Service -> Google Service)
    # required for querying columns with privacy tags in src_ds from the subscriber projects
    {
      "from" = {
        "identities" = var.publ_vpc_sc_ah_subscriber_identities
      }
      "to" = {
        "resources" = local.vpc_sc_ah_subscriber_project_resources_with_numbers
        "operations" = {
          "bigquerydatapolicy.googleapis.com" = {
            "permissions" = []
            "methods" = [
              "*",
            ]
          },
          "bigquery.googleapis.com" = {
            "methods" = [
            ]
            "permissions" = [
              "datacatalog.categories.fineGrainedGet",
              "bigquery.jobs.create",
            ]
          },
        }
      }
    },
  ]
}

module "regular_service_perimeter_bq_shared_ds" {
  source  = "terraform-google-modules/vpc-service-controls/google//modules/regular_service_perimeter"
  version = "7.0.0"

  policy         = google_access_context_manager_access_policy.access_policy.id
  perimeter_name = "ahdemo_${var.name_suffix}_publ_bq_shared_ds"
  description    = "ahdemo_${var.name_suffix}_publ_bq_shared_ds"

  restricted_services = var.vpc_sc_dry_run ? [] : var.vpc_sc_restricted_services
  restricted_services_dry_run = var.vpc_sc_dry_run ? var.vpc_sc_restricted_services : []

  access_levels = []

  resources = var.vpc_sc_dry_run ? [] : [ data.google_project.publ_bq_shared_ds.number ]
  resources_dry_run = var.vpc_sc_dry_run ? [ data.google_project.publ_bq_shared_ds.number ] : []
  
  ingress_policies = var.vpc_sc_dry_run ? [] : local.ingress_policies_bq_perimeter_shared_ds
  ingress_policies_dry_run = var.vpc_sc_dry_run ? local.ingress_policies_bq_perimeter_shared_ds : []
  egress_policies = var.vpc_sc_dry_run ? [] : local.egress_policies_bq_perimeter_shared_ds
  egress_policies_dry_run = var.vpc_sc_dry_run ? local.egress_policies_bq_perimeter_shared_ds : []
}
