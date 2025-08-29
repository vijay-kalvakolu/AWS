#Google Clod SQl for MySQL

#// CLOUD SQL is used to setup DB as recommeded by OBS woth 8.0. here key settings inlude :
# Enableing automated backups, enableing point-in-time recovery and 
# Configuring it to use a private ip address within our vpc for secure connectivity
#//
resource "google_sql_database_instance" "observium_db" {
    name = "observium-db-instance"
    database_version = "MYSQL_8_0"
    region = var.region
    project = var.project_id

    settings {
        tier = "db-n1-standard-1"
        ip_configuration {
            ipv4_enabled = false
            private_network = google_compute_network.obs-vpc.id
        }
        backup_configuration {
            enabled = true
            point_in_time_recovery_enabled = true
        }
    }

    deletion_protection = false # set to true for production environemnts
}

# Filestoer for RRD data

resource "google_filestore_instance" "observium_rrd" {
name = "observium-rrd-share"
location = var.zone
tier = "BASIC_SSD" # modify based on performance needs
project = var.project_id

file_shares {
    capacity_gb = 40 # adjust storage accordingly 
    name = "rrd"
}
networks {
    network = google_compute_network.obs-vpc.id
    modes = ""
}

}