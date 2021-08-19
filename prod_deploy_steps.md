## cleanup of state after dev deployment
Required because I was running the code from the same compute (local)
1. remove IaC/.terraform 
1. remove IaC/prerequisites/.terraform 
1. rename IaC/terraform.state -> IaC/terraform_dev.state.backup
1. rename IaC/prerequisites/terraform.state -> IaC/terraform_dev.state.backup

## Updated vars file manually
vi vars
Applied these switches for a project tht was fresh:
export APP_EXISTS=1  (API already enabled, app exists in us central)
export TF_VAR_create_brand=1  (trigger creating brand)
export TF_VAR_brand_name=
added: subnet variable, and added to all modules of terraform  - since it is specified. 

source_ranges = ["192.168.1.0/24"] #changed to the exact range in the project's existing subnet. 


## Ran the first part of the make file which did:
dependencies-checks: (for installed libraries)
	@chmod +x ./bin/check_dependencies.sh
	@cd bin && ./check_dependencies.sh

## Ran the prerequesites Terraform
1. enables APIs (I changed the policy so they would not be disabled on destroy)
1. creates bucket for statefile
source vars && cd IaC/prerequesites && terraform init && terraform apply

## Can ignore the shell scripts for config -> Vars, I set them manually
Can skip this in the shell scripts: set_app_engine set-various set-network set-support-email set-users

Note: I am removing the domain config option through terraform becasue it failed. 

## Built the docker image:
source vars && gcloud builds submit --tag $TF_VAR_mlflow_docker_image ./tracking_server 
Note the Dockerfile is in ./tracking_server/Dockerfile

I hit an error and with changinf libraries. Modified Docker file:
apt-get update --allow-releaseinfo-change

## Initialised Terraform init-terraform
This deletes the current .terraform, then intitialises
source vars && cd IaC && rm -rf .terraform && terraform init -backend-config="bucket=$TF_VAR_backend_bucket"

## Handle the potential exisitng infra import-oauth-stuff
..... ignoring this for now and manually switching in vars. May complain. 

## Applied Terraform  apply-terraform
source vars && cd IaC && terraform plan
source vars && cd IaC && terraform apply


## Manually added users to the IAP client for appEngine MLFlow...

Removed the woolies domain config because it was failing:
resource "google_iap_app_engine_service_iam_member" "member" {
  for_each = toset(var.web_app_users)
  project  = data.google_project.project.project_id
  app_id   = data.google_project.project.project_id
  service  = google_app_engine_flexible_app_version.mlflow_app.service
  role     = "roles/iap.httpsResourceAccessor"
  member   = each.key
}

## Tested the functionality of MLFlow

## Retrieved and shared the:
- URL for MLFlow Server
- Bucket for Artefacts
- Code for working with the remote server

