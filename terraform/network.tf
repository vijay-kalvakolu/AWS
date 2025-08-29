
resource "google_compute_network" "obs-vpc" {
    project = "var.project_id"
    name = "obs-vpc"
    auto_create_subnetworks = false
    routing_mode = "REGIONAL"
}

resource "google_compute_subnetwork" "gke-private-sn" {
    name = "gke-private-sn"
    ip_cidr_range = "10.10.0.0/20"
    region = "var.region"
    network = google_compute_network.obs-vpc.id
    private_ip_google_access = true

    secondary_ip_range {
        range_name = "gke-pod-range"
        ip_cidr_range = "10.20.0.0/20"
    }
    
    secondary_ip_range {
        range_name = "gke-service-range"
        ip_cidr_range = "10.30.0.0/20"
    }
}

resource "google_compute_router" "nat_router" {
    name = "observium-nat-router"
    region = var.region
    network = google_compute_network.obs-vpc.id
}

resource "google_compute_router_nat" "nat_gateway" {
    name = "obs-nat-gw"
    router = google_compute_router.nat_router.name
    region = var.region
    source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
    subnetwork {
        name =google_compute_subnetwork.gke-private-sn.id
        source_ip_ranges_to_nat = 
    }
}