#!/bin/bash

# USAGE: Use without arguments in a jenkins test job to build and test the image. This keeps jenkins job config complexity low.

THIS_DIR="$(cd "$(dirname "$0")"; pwd)"
BASE_DIR="$(dirname $THIS_DIR)"

export DEBUG_VERSION="a.b.c"

# TODO: UNCOMMENT: $THIS_DIR/build && $THIS_DIR/test || exit 1
