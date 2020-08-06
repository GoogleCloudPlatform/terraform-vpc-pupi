/*
Copyright 2020 Google LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

#<!--* freshness: { owner: 'ttaggart@google.com' reviewed: '2020-aug-01' } *-->


# *********** [ Producer Network ] *************
# **********************************************
resource "google_compute_network" "producer" {
  provider                = "google-beta"
  name                    = "producer"
  auto_create_subnetworks = "false"
  routing_mode            = "GLOBAL"
  project                 = "${google_project.pupi.project_id}"

  depends_on = [
    # The project's services must be set up before the
    # network is enabled as the compute API will not
    # be enabled and cause the setup to fail.
    "google_project_service.compute_api",
  ]

  timeouts {
    create = "10m"
    delete = "10m"
  }
}

resource "google_compute_subnetwork" "producer_gke" {
  provider      = "google-beta"
  region        = "${var.region1}"
  name          = "producer-nodes"
  ip_cidr_range = "10.128.0.0/24"
  project       = "${google_project.pupi.project_id}"
  network       = "${google_compute_network.producer.self_link}"

  secondary_ip_range {
    range_name    = "producer-pods"
    ip_cidr_range = "45.45.45.0/24"
  }  

  secondary_ip_range {
    range_name    = "producer-cluster"
    ip_cidr_range = "172.16.45.0/24"
  }

  timeouts {
    create = "10m"
    delete = "10m"
  }
}


# *********** [ Consumer Network ] *************   
# **********************************************
resource "google_compute_network" "consumer" {
  provider                = "google-beta"
  name                    = "consumer"
  auto_create_subnetworks = "false"
  routing_mode            = "GLOBAL"
  project                 = "${google_project.pupi.project_id}"

  depends_on = [
    # The project's services must be set up before the
    # network is enabled as the compute API will not
    # be enabled and cause the setup to fail.
    "google_project_service.compute_api",
  ]

  timeouts {
    create = "10m"
    delete = "10m"
  }
}

resource "google_compute_subnetwork" "consumer_gke" {
  provider      = "google-beta"
  region        = "${var.region2}"
  name          = "consumer-nodes"
  ip_cidr_range = "10.129.0.0/24"
  project       = "${google_project.pupi.project_id}"
  network       = "${google_compute_network.consumer.self_link}"

  secondary_ip_range {
    range_name    = "consumer-pods"
    ip_cidr_range = "5.5.5.0/24"
  }

  secondary_ip_range {
    range_name    = "consumer-cluster"
    ip_cidr_range = "172.16.5.0/24"
  }

  timeouts {
    create = "10m"
    delete = "10m"
  }
}


/*
# Removing peering config as Terraform does not support PUPI
# at this time.
# *********** [ Consumer Network ] *************
# **********************************************
resource "google_compute_network_peering" "consumer" {
  provider             = "google-beta"
  name                 = "consumer"
  network              = google_compute_network.consumer.self_link
  peer_network         = google_compute_network.producer.self_link

  export_custom_routes = "true"
  import_custom_routes = "false"
}

resource "google_compute_network_peering" "producer" {
  provider             = "google-beta"
  name                 = "producer"
  network              = google_compute_network.producer.self_link
  peer_network         = google_compute_network.consumer.self_link
  export_custom_routes = "false"
  import_custom_routes = "true"
}
*/
