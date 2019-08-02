#!/bin/bash

THIS_DIR="$(cd "$(dirname "$0")"; pwd)"
BASE_DIR="$(dirname $THIS_DIR)"

. $BASE_DIR/lib/bash_include/extract_vault_secrets.sh

# TODO: what is the best practice for docker prune on jenkins nodes?

# TODO: point jenkins job at master eventually
# TODO: maybe another jenkins job and corresponding script for testing? (build, and then: (from Jon) "I think just starting the container, and possibly mapping in a generic webapp.conf file to have it start up nginx and expose port 80 or 443 and make a GET on localhost" )

export JENKINS_VAULT_TOKEN_PATH=/home/jenkins/temp-vault-token
export VAULT_ADDR=https://clotho.broadinstitute.org:8200

# login to dockerhub
SCPDOCKERHUB_VAULT_PATH="secret/kdux/scp/production/scp_dockerhub_credentials.json"
extract_vault_secrets_as_env_file "$SCPDOCKERHUB_VAULT_PATH" || exit 1
. "$(determine_export_filepath $SCPDOCKERHUB_VAULT_PATH bash)" || exit 1
echo "$DOCKERHUB_PASSWORD" | docker login -u "$DOCKERHUB_USERNAME" --password-stdin || exit 1

$THIS_DIR/build && $THIS_DIR/publish || exit 1
