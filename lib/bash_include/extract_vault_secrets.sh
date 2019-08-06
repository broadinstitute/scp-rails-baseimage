#!/usr/bin/env bash

# load secrets from Vault for building/publishing SCP docker container

# defaults
DOCKER_IMAGE_FOR_VAULT_CLIENT='vault:1.1.3'
export VAULT_ADDR
export JENKINS_VAULT_TOKEN_PATH

# load common utils
. $BASE_DIR/lib/bash_include/bash_utils.sh || exit 1

function determine_export_filepath {
    echo "$BASE_DIR/tmp/secrets/$(determine_export_filename "$1" "$2" )"
}

# extract filename from end of vault path, replacing with new extension if needed
function determine_export_filename {
    SECRET_PATH="$1"
    REQUESTED_EXTENSION="$2"
    FILENAME=$(basename $SECRET_PATH)
    if [[ -n "$REQUESTED_EXTENSION" ]]; then
        # replace existing extension with requested extension (like .env for non-JSON secrets)
        EXPORT_EXTENSION="$(set_pathname_extension $FILENAME)"
        FILENAME="${FILENAME//$EXPORT_EXTENSION/$REQUESTED_EXTENSION}" || exit_with_error_message "could not change export filename extension to $REQUESTED_EXTENSION from $EXPORT_EXTENSION"
    fi
    echo "$FILENAME"
}

# extract generic JSON vault secrets and
function extract_vault_secrets_as_env_file {
    VAULT_SECRET_PATH="$1"
    echo "setting filename for $VAULT_SECRET_PATH export"
    SECRET_EXPORT_FILEPATH="$(determine_export_filepath $VAULT_SECRET_PATH bash)" || exit 1
    # load raw secrets from vault
    echo "extracting vault secrets from $VAULT_SECRET_PATH"
    VALS=$(load_secrets_from_vault $VAULT_SECRET_PATH) || exit_with_error_message "could not read secrets from $VAULT_SECRET_PATH"

    mkdir -p "$(dirname "$SECRET_EXPORT_FILEPATH" )" || exit 1
    echo "### env secrets from $VAULT_SECRET_PATH ###" >| $SECRET_EXPORT_FILEPATH || exit_with_error_message "could not initialize $SECRET_EXPORT_FILEPATH"
    # for each key in the secrets config, export the value
    for key in $(echo $VALS | jq .data | jq --raw-output 'keys[]')
    do
        echo "setting value for: $key"
        curr_val=$(echo $VALS | jq .data | jq --raw-output .$key) || exit_with_error_message "could not extract value for $key from $VAULT_SECRET_PATH"
        echo "export $key='$curr_val'" >> $SECRET_EXPORT_FILEPATH
    done
    unset VALS key
}

function get_authentication_method {
    if [[ -f $JENKINS_VAULT_TOKEN_PATH ]]; then
        echo "-method=token -no-print=true token=$(cat $JENKINS_VAULT_TOKEN_PATH)"
    else
        echo "-method=github -no-print=true token=$(cat ~/.github-token-for-vault)"
    fi
}

# load secrets out of vault using Docker image defined in $DOCKER_IMAGE_FOR_VAULT_CLIENT
# will auto-detect correct vault authentication method based on presence of $JENKINS_VAULT_TOKEN_PATH
function load_secrets_from_vault {
    SECRET_PATH_IN_VAULT="$1"

    docker run --rm \
        -e VAULT_AUTH_GITHUB_TOKEN \
        -e VAULT_AUTH_NATIVE_TOKEN \
        -e VAULT_ADDR \
        $DOCKER_IMAGE_FOR_VAULT_CLIENT \
        sh -lc "vault login $(get_authentication_method) && vault read -format json $SECRET_PATH_IN_VAULT" || exit_with_error_message "could not read $SECRET_PATH_IN_VAULT"
}

