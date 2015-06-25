cite about-plugin
about-plugin 'Helpers to get Docker setup correctly for boot2docker and to more easily work with Docker'

# Note, this might need to be different if you have an older version
# of boot2docker, or its configured for a different IP
if [[ `uname -s` == "Darwin" ]]; then
  export DOCKER_HOST=tcp://192.168.59.103:2376
  export DOCKER_CERT_PATH=~/.boot2docker/certs/boot2docker-vm
  export DOCKER_TLS_VERIFY=1

  docker-enter() {
    boot2docker ssh '[ -f /var/lib/boot2docker/nsenter ] || docker run --rm -v /var/lib/boot2docker/:/target jpetazzo/nsenter'
    boot2docker ssh -t sudo "/var/lib/boot2docker/docker-enter \"$1\""
  }
fi

function docker-remove-most-recent-container() {
  about 'attempt to remove the most recent container from docker ps -a'
  group 'docker'
  docker ps -a | head -2 | tail -1 | awk '{print $NF}' | xargs docker rm
}

function docker-remove-most-recent-image() {
  about 'attempt to remove the most recent image from docker images'
  group 'docker'
  docker images | head -2 | tail -1 | awk '{print $3}' | xargs docker rmi
}

function docker-remove-images() {
  about 'attempt to remove images with supplied tags or all if no tags are supplied'
  group 'docker'
  if [ -z "$1" ]; then
    docker rmi $(docker images -q)
  else
    DOCKER_IMAGES=""
    for IMAGE_ID in $@; do DOCKER_IMAGES="$DOCKER_IMAGES\|$IMAGE_ID"; done
    # Find the image IDs for the supplied tags
    ID_ARRAY=($(docker images | grep "${DOCKER_IMAGES:2}" | awk {'print $3'}))
    # Strip out duplicate IDs before attempting to remove the image(s)
    docker rmi $(echo ${ID_ARRAY[@]} | tr ' ' '\n' | sort -u | tr '\n' ' ')
 fi
}

function docker-image-dependencies() {
  about 'attempt to create a Graphiz image of the supplied image ID dependencies'
  group 'docker'
  if hash dot 2>/dev/null; then
    OUT=$(mktemp -t docker-viz-XXXX.png)
    docker images -viz | dot -Tpng > $OUT
    case $OSTYPE in
      linux*)
        xdg-open $OUT
        ;;
      darwin*)
        open $OUT
        ;;
    esac
  else
    >&2 echo "Can't show dependencies; Graphiz is not installed"
  fi
}

function docker-runtime-environment() {
  about 'attempt to list the environmental variables of the supplied image ID'
  group 'docker'
  docker run "$@" env
}
