# Keyless secrer management worklfow using Google Secret Manager and workload Identity

# 1. Store the secret
# 2. create a gcp secret service account (SA)
# 3. grant iam permissions
# 4. Bind kubernetes SA to GCP SA

resource "random_password" "db_password" {
    length = 24
    special = true
}

resource "google_secret_manager_secret" "db_password_secret" {
    secret_id = "observium-db-password"
project = var.project_id
replication {
  automatic = true
}
}