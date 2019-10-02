#!/bin/bash

# USAGE: Use without arguments in a jenkins test job to build and test the image. This keeps jenkins job config complexity low.

echo "DEBUG: (in jenkins.build-and-test.bash) \$BASH_SOURCE is \"$BASH_SOURCE\""
THIS_DIR="$(cd "$(dirname "$BASH_SOURCE")"; pwd)"
BASE_DIR="$(dirname $THIS_DIR)"
BASH_INCLUDE="$BASE_DIR/lib/bash_include"

echo DEBUG: ls $BASE_DIR
ls $BASE_DIR
echo DEBUG: ls $BASE_DIR/lib
ls $BASE_DIR/lib
echo DEBUG: ls $BASE_DIR/lib/bash_include
ls $BASE_DIR/lib/bash_include
echo DEBUG: ls $BASH_INCLUDE
ls $BASH_INCLUDE
echo DEBUG: ls $BASH_INCLUDE/bash_utils.bash
ls $BASH_INCLUDE/bash_utils.bash
. $BASH_INCLUDE/bash_utils.bash

$THIS_DIR/build || exit_with_error_message "build failed (at $BASH_SOURCE:$LINENO)"
$THIS_DIR/test  || exit_with_error_message "test failed (at $BASH_SOURCE:$LINENO)"
