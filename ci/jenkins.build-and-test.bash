#!/bin/bash

# USAGE: Use without arguments in a jenkins test job to build and test the image. This keeps jenkins job config complexity low.

THIS_DIR="$(cd "$(dirname "$BASH_SOURCE")"; pwd)"
BASE_DIR="$(dirname $THIS_DIR)"
BASH_INCLUDE="$BASE_DIR/lib/bash_include"

. $BASH_INCLUDE/show_banner.bash
. $BASH_INCLUDE/bash_utils.bash

$THIS_DIR/build || exit_with_error_message "build FAILED"
$THIS_DIR/test  || exit_with_error_message "test FAILED"
$THIS_DIR/check_for_newer_dependencies || { echo "WARNING: Setting jenkins job to unstable to trigger email for new dependency versions that this build has not adopted yet..." >&2; exit 99; }
