#!/bin/bash

# USAGE: Use without arguments in a jenkins test job to build and test the image. This keeps jenkins job config complexity low.

THIS_DIR="$(cd "$(dirname "$BASH_SOURCE")"; pwd)"
BASE_DIR="$(dirname $THIS_DIR)"
BASH_INCLUDE="$BASE_DIR/lib/bash_include"

. $BASH_INCLUDE/bash_utils.bash

$THIS_DIR/build || exit_with_error_message "build failed (at $BASH_SOURCE:$LINENO)"
$THIS_DIR/test  || exit_with_error_message "test failed (at $BASH_SOURCE:$LINENO)"
