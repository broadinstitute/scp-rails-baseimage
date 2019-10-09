#!/bin/bash

# USAGE: Use without arguments in a jenkins test job to build and test the image. This keeps jenkins job config complexity low.

echo "DEBUG: (in jenkins.build-and-test.bash) \$BASH_SOURCE is \"$BASH_SOURCE\""
THIS_DIR="$(cd "$(dirname "$BASH_SOURCE")"; pwd)"
BASE_DIR="$(dirname $THIS_DIR)"
BASH_INCLUDE="$BASE_DIR/lib/bash_include"

. $BASH_INCLUDE/bash_utils.bash

$THIS_DIR/clean || exit_with_error_message "clean failed (at $BASH_SOURCE:$LINENO)"
$THIS_DIR/build || exit_with_error_message "build failed (at $BASH_SOURCE:$LINENO)"
$THIS_DIR/test  || exit_with_error_message "test failed (at $BASH_SOURCE:$LINENO)"
