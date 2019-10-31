#!/bin/bash

# USAGE: Use without arguments in a jenkins test job to build and test the image. This keeps jenkins job config complexity low.

THIS_DIR="$(cd "$(dirname "$BASH_SOURCE")"; pwd)"
BASE_DIR="$(dirname $THIS_DIR)"
BASH_INCLUDE="$BASE_DIR/lib/bash_include"

. $BASH_INCLUDE/bash_utils.bash
. $BASE_DIR/lib/bash_include/extract_vault_secrets.bash

export JENKINS_VAULT_TOKEN_PATH=/home/jenkins/temp-vault-token

# login to dockerhub
SCPDOCKERHUB_VAULT_PATH="secret/kdux/scp/production/scp_dockerhub_credentials.json"
. "$(extract_vault_secrets_as_env_file "$SCPDOCKERHUB_VAULT_PATH" )" || exit 1
echo "$DOCKERHUB_PASSWORD" | docker login -u "$DOCKERHUB_USERNAME" --password-stdin || exit 1

$THIS_DIR/clean && $THIS_DIR/build && $THIS_DIR/test && $THIS_DIR/publish || exit 1
