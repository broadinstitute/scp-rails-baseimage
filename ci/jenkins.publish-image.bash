#!/bin/bash

THIS_DIR="$(cd "$(dirname "$0")"; pwd)"

# TODO: what is the best practice for docker prune on jenkins nodes?

# TODO: point jenkins job at master eventually
# TODO: maybe another jenkins job and corresponding script for testing? (build, and then: (from Jon) "I think just starting the container, and possibly mapping in a generic webapp.conf file to have it start up nginx and expose port 80 or 443 and make a GET on localhost" )

$THIS_DIR/build && $THIS_DIR/publish || exit 1
