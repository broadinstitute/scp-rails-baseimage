if ! [ -d "$BASE_DIR" ]; then
    echo "ERROR: $(basename $BASH_SOURCE): \$BASE_DIR should already be defined before this was included at $BASH_SOURCE[1]" >&2
    exit 1
fi

. "$BASE_DIR/requirements.bash"

DOCKER_NAMESPACE="singlecellportal"
MAIN_IMAGE_NAME="rails-baseimage"
MAIN_IMAGE_FULLNAME="$DOCKER_NAMESPACE/$MAIN_IMAGE_NAME"

PHUSION_BASE_IMAGE_REPO_RELEASE_TAG="$PHUSION_BASE_IMAGE_VERSION"
PHUSION_PASSENGER_IMAGE_REPO_RELEASE_TAG="rel-$PHUSION_PASSENGER_IMAGE_VERSION"

IMAGE_REPOS_DIR="$BASE_DIR/tmp"

. "$BASE_DIR/lib/bash_include/github.bash"

PHUSION_BASE_IMAGE_NAME="$(new_image_name_from_repo $PHUSION_BASE_IMAGE_REPO)"
PHUSION_PASSENGER_IMAGE_NAME="$(new_image_name_from_repo $PHUSION_PASSENGER_IMAGE_REPO)"