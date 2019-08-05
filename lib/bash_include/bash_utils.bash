#!/usr/bin/env bash

# common functions to share amongst different bash scripts for building/publishing SCP docker container

# https://stackoverflow.com/a/56841815/1735179
export newline='
'

# exit 1 with an error message
function exit_with_error_message {
    echo "ERROR: $@" >&2;
    exit 1
}

function set_pathname_extension {
    FULL_PATH="$1"
    SEP="."
    echo ${FULL_PATH##*$SEP} || exit_with_error_message "could not extract file extension from $FULL_PATH"
}
