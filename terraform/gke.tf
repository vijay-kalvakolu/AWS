# GKE cluster is provisoned with a focus on securoty, high availability and modren best practices.
# REGIONAL CLUSTER : specifying a location at region level instead of zone creates a regional cluste. This provides high availability for the kubernetes control plane by distributinf it across multiple zones

resource "google_container_cluster" "primary" {
    name = "observium-cluster"
    location = var.region
    project = var.project_id

    # Networking

    network = google_compute_network.obs-vpc.id
    subnetwork = google_compute_subnetwork.gke-private-sn.id
    ip_allocation_policy {
        cluster_secondary_range_name = google_compute_subnetwork.secondary_ip_range_name
        services_secondary_range_name = google_compute_subnetwork.secondary_ip_range_name
    }

# Security
# PRIVATE CLUSTER : by setting the cluster to private, we ensure that worker nodes are provsioned without external IP addresses, isolating them within our private subnet. 

private_cluster_config {
    enable_private_nodes = true
    enable_private_endpoint = false # Master accessible via public endpoint
    master_ipv4_cidr_block = "172.16.0.0/28"
}

master_authorized_networks_config {
    cidr_blocks{
        cidr_block = "0.0.0.0/0" # our public ip
        display_name = "Access-for-obs"
    }
}
# WORKLOAD IDENTITY : we are enableing GKEs recommended authentication mechanisi by setting up the worload_identity_config block.
# This allows k8 service accounts to impersonates Google Cloud Service Accounts, providing a secure, keyless way for pods to access other Google Cloud services.

workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
}

#NETWORK POLICY : to enable micro segmentation within the cluster we will enable network policy enforcement from the outset by setting networki policy nebaled = true and specifying CALICO as the provider.    

network_policy {
    enabled = true
    provider = "CALICO"
}

# Remove default node pool, we will manage them separately
remove_default_node_pool = true
initial_node_count = 1

# Enable filestore CSI Driver
addons_config {
    gcp_filestore_csi_driver_config {
      enabled = true
        }
    }

}