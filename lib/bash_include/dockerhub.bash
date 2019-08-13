if ! [ -d "$BASE_DIR" ]; then
    echo "ERROR: $(basename $BASH_SOURCE): \$BASE_DIR should already be defined before this was included at $BASH_SOURCE[1]" >&2
    exit 1
fi

. "$BASE_DIR/lib/bash_include/config.bash"

# making sure publish fails if version.txt has not been updated to avoid re-using the version tag:
function assert_main_version_unused {
    if main_version_already_published; then
        exit_with_error_message "version $MAIN_VERSION has already been published. Please edit version.txt according to semver and try again." >&2
    fi
}

function main_version_already_published {
    docker_image_has_been_published "hub.docker.com" "$MAIN_IMAGE_FULLNAME" "$MAIN_VERSION"
}

function docker_image_has_been_published {

    local REGISTRY="$1"
    local IMAGE_SCOPED_NAME="$2"
    local TAG="$3"

    if docker_image_has_been_published_unsafe "$REGISTRY" "$IMAGE_SCOPED_NAME" "latest"; then
        docker_image_has_been_published_unsafe "$REGISTRY" "$IMAGE_SCOPED_NAME" "$TAG"
    else
        echo "ERROR: $(basename $0): cannot confirm what has previously published."
        exit 1
    fi

}

function docker_image_has_been_published_unsafe {
    local REGISTRY="$1"
    local IMAGE_SCOPED_NAME="$2"
    local TAG="$3"

    TAG_TEST_URL="https://$REGISTRY/v2/repositories/$IMAGE_SCOPED_NAME/tags/$TAG/"
    HTTP_CODE="$(curl -X "HEAD" -L -s -w "%{http_code}" "$TAG_TEST_URL" -m 2 )"
    [ "200" == "$HTTP_CODE" ]
}


