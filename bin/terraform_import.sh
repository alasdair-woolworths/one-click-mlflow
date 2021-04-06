#!/bin/bash

if terraform state list module.mlflow.module.server.google_app_engine_application.app 1> /dev/null 2> /dev/null ; then
    app_in_state=1
else
    app_in_state=0
fi

if [ "$app_exists" == 1 ] && [ "$app_in_state" == 0 ]; then
    echo Importing app engine service
    terraform import module.mlflow.module.server.google_app_engine_application.app $TF_VAR_project_id
fi


if gcloud alpha iap oauth-brands list | grep "name: " 1> /dev/null 2> /dev/null; then
  echo "A consent screen (brand) has already been configured on this project. It will be used as-is"
  export BRAND_EXISTS=1
  echo export TF_VAR_brand_exists=1 >> ../vars_additionnal
  BRAND_NAME="projects/$TF_VAR_project_number/brands/$TF_VAR_project_number"
  echo export TF_VAR_brand_name=$BRAND_NAME >> ../vars_additionnal
else
  echo "No consent screen (brand) has been configured on this project, a new one will be created"
  export BRAND_EXISTS=0
  echo "No oauth client exists on this project. A new one will be created"
  echo export TF_VAR_brand_exists=0 >> ../vars_additionnal
  echo export TF_VAR_oauth_client_id="" >> ../vars_additionnal
  echo export TF_VAR_oauth_client_secret="" >> ../vars_additionnal
fi


if [ $BRAND_EXISTS == 1 ]; then
  CLIENT_DESCRIPTION=$(gcloud --format json alpha iap oauth-clients list "$BRAND_NAME")

  if [ "$CLIENT_DESCRIPTION" != '[]' ]; then
    echo "An oauth client has already been created on this project. It will be used for IAP access"
    echo export TF_VAR_oauth_client_id=$(echo "$CLIENT_DESCRIPTION" | jq '.[0].name' | tr -d '"' | sed 's:.*/::') >> ../vars_additionnal
    echo export TF_VAR_oauth_client_secret=$(echo "$CLIENT_DESCRIPTION" | jq '.[0].secret' | tr -d '"') >> ../vars_additionnal

  else
    echo "No oauth client exists on this project. A new one will be created"
    echo export TF_VAR_oauth_client_id="" >> ../vars_additionnal
    echo export TF_VAR_oauth_client_secret="" >> ../vars_additionnal
  fi
fi