#!/usr/bin/env bash

# common functions to share amongst different bash scripts for building/publishing SCP docker container

# https://stackoverflow.com/a/56841815/1735179
export newline='
'

# exit 1 with an error message
function exit_with_error_message {
    echo "ERROR: $@ (at ${BASH_SOURCE[1]}:$BASH_LINENO)" >&2;
    exit 1
}

function get_file_extension_from_path {
    FULL_PATH="$1"
    SEP="."
    echo ${FULL_PATH##*$SEP} || exit_with_error_message "Could not extract file extension from $FULL_PATH"
}
