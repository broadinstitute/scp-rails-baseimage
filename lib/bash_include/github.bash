. $BASE_DIR/lib/bash_include/bash_utils.bash || exit 1 # load common utils

function github_checkout {
    GITHUB_REPO_NAME="$1"
    CLONE_DIR="$2"
    TAG="$3"

    if [ -z "$TAG" ];then exit_with_error_message "github_checkout requires a tag";fi

    CLONE_REPO="https://github.com/$GITHUB_REPO_NAME.git" # https means we don't need to deal with ssh known_hosts or any authentication at all

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
    dir_name_from_repo $1 | sed 's/[-]docker//'
}

function dir_name_from_repo {
    echo $1 | sed 's/\//_/'
}

function report_local_repository_state {
    cd "$1" || exit_with_error_message "Could not cd to $1"
    echo "image was built from repository: $(git config --get remote.origin.url), commit $(git rev-parse HEAD), tag $(git tag --points-at HEAD)"
    GIT_COMMAND_SHOW_LOCAL_CHANGES="git status -vv"
    echo "...with the following local changes, as reported by \"$GIT_COMMAND_SHOW_LOCAL_CHANGES\": $(echo;$GIT_COMMAND_SHOW_LOCAL_CHANGES)"
}
