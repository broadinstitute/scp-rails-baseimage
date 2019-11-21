# This file contains functionality for docker registries, and some of it may assume the registry is dockerhub

if ! [ -d "$BASE_DIR" ]; then
    exit_with_error_message "\$BASE_DIR should already be defined before this was included at ${BASH_SOURCE[1]}:${BASH_LINENO}"
fi

. "$BASE_DIR/lib/bash_include/config.bash"

# making sure publish fails if version.txt has not been updated to avoid re-using the version tag:
function assert_main_version_unused {
    if main_version_already_published; then
        exit_with_error_message "Version $MAIN_VERSION has already been published, and refers to a different image. Something must have changed, perhaps a newer version of $BASE_IMAGE (BASE_IMAGE). Please edit version.txt according to semver and try again to publish these changes."
    fi
}

function main_version_already_published {
    docker_image_has_been_published "hub.docker.com" "$MAIN_IMAGE_FULLNAME" "$MAIN_VERSION"
}

function docker_image_has_been_published {

    local REGISTRY="$1"
    local IMAGE_SCOPED_NAME="$2"
    local TAG="$3"

    max_attempts=3
    attempt_number=1
    until docker_image_has_been_published_unsafe "$REGISTRY" "$IMAGE_SCOPED_NAME" "latest"; do
        if [ "$attempt_number" -gt "$max_attempts" ]; then
            exit_with_error_message "FAILED to verify that image \"$IMAGE_SCOPED_NAME:latest\" has been previously published, which probably just means we cannot reach the registry ( $REGISTRY/ )."
        else
            echo "It seems like we cannot reach the docker registry right now (attempt $attempt_number), will try again shortly..."
            sleep 5
        fi
        attempt_number="$(($attempt_number + 1))"
    done
    docker_image_has_been_published_unsafe "$REGISTRY" "$IMAGE_SCOPED_NAME" "$TAG" #un-explicitly sets the return value
}

function docker_image_has_been_published_unsafe {
    local REGISTRY="$1"
    local IMAGE_SCOPED_NAME="$2"
    local TAG="$3"

    TAG_TEST_URL="https://$REGISTRY/v2/repositories/$IMAGE_SCOPED_NAME/tags/$TAG/"
    HTTP_CODE="$(curl -X "HEAD" -L -s -w "%{http_code}" "$TAG_TEST_URL" -m 2 )"
    [ "200" == "$HTTP_CODE" ] # no explicit return or if statement needed
}

function docker_force_pull {
    local IMAGE="$1"

    echo "Forcefully pulling a fresh version of the docker image \"$IMAGE\":" >&2
    if docker inspect $IMAGE --format '.' >/dev/null 2>&1; then # if IMAGE exists
        docker tag $IMAGE temp || { echo "ERROR: FAILED at $BASH_SOURCE:$LINENO" >&2; return 1; }
        docker rmi $IMAGE || { echo "ERROR: FAILED at $BASH_SOURCE:$LINENO" >&2; return 1; }
    fi

    docker pull $IMAGE || { echo "ERROR: FAILED at $BASH_SOURCE:$LINENO" >&2; return 1; }
    echo "...got a fresh version of the docker image \"$IMAGE\"." >&2

    if docker inspect temp --format '.' >/dev/null 2>&1; then # if temp image exists
        docker rmi temp || { echo "ERROR: FAILED at $BASH_SOURCE:$LINENO" >&2; return 1; }
    fi
    return 0
}
