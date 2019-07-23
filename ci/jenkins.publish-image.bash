#!/bin/bash

THIS_DIR="$(cd "$(dirname "$0")"; pwd)"

# TODO: what is the best practice for docker prune on jenkins nodes?

# TODO: point jenkins job at master eventually
# TODO: maybe another jenkins job and corresponding script for testing?

$THIS_DIR/build && $THIS_DIR/publish || exit 1
