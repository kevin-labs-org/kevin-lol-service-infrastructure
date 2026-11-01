resource "google_cloudbuildv2_connection" "my_connection" {
  location = "us-central1"
  name     = "my-github-connection"

  github_config {
    app_installation_id = 12345678 # Your GitHub App Installation ID
    authorizer_credential {
      oauth_token_secret_version = "projects/my-project/secrets/github-oath-token/versions/1"
    }
  }
}

resource "google_cloudbuildv2_repository" "my_repo" {
  name              = "my-application-repo"
  parent_connection = google_cloudbuildv2_connection.my_connection.id
  remote_uri        = "https://github.com"
}

resource "google_cloudbuild_trigger" "build_trigger" {
  location = "us-central1"

  repository_event_config {
    repository = google_cloudbuildv2_repository.my_repo.id

    push {
      branch = "^main$"
    }
  }

  substitutions = {
    _PROJECT_ID = var.project_id
    _LOCATION     = "us-central1"
    _IMAGE     = local.application_name
    _REPOSITORY = module.artifact_registry.artifact_name
    _SERVICE_NAME    = local.application_name
    _SERVICE_REGION = "us-central1"
  }

  filename = "cloudbuild.yaml"
}
