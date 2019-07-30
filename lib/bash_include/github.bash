
function github_checkout {
    GITHUB_REPO_NAME="$1"
    CLONE_DIR="$2"
    TAG="$3"

    if [ -z "$TAG" ];then echo "ERROR: github_checkout requires a tag" >&2;exit 1;fi

    # TODO: use a read-only URL so jenkins can succeed
    CLONE_REPO="git@github.com:$GITHUB_REPO_NAME.git" # TODO: DELETE
    CLONE_REPO="git://github.com/$GITHUB_REPO_NAME.git" # read-only form of the URL # TODO: DELETE
    CLONE_REPO="https://github.com/$GITHUB_REPO_NAME.git" # https means we don't need to deal with ssh known_hosts

    mkdir -p $(dirname $CLONE_DIR)
    if ! [ -d  $CLONE_DIR ]; then
        git clone --branch $TAG $CLONE_REPO -- $CLONE_DIR || exit 1
    fi
    pushd $CLONE_DIR || exit 1
    git fetch -a || exit 1
    git checkout -- . || exit 1
    git checkout $TAG -- || exit 1
    echo "$CLONE_DIR is at $TAG"
    [ "$TAG" == "$(git tag --points-at HEAD)" ] || exit 1 # confirmation
    [ "" == "$(git status --porcelain)" ] || exit 1 # confirmation
    popd
}

function new_image_name_from_repo {
    dir_name_from_repo $1 | sed 's/[-]\?docker//'
}

function dir_name_from_repo {
    echo $1 | sed 's/\//_/'
}
