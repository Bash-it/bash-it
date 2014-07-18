cite about-plugin
about-plugin 'Helpers to get Docker setup correctly for boot2docker'

# Note, this might need to be different if you have an older version
# of boot2docker, or its configured for a different IP
if [[ `uname -s` == "Darwin" ]]; then
  export DOCKER_HOST=tcp://192.168.59.103:2375

  docker-enter() {
    boot2docker ssh '[ -f /var/lib/boot2docker/nsenter ] || docker run --rm -v /var/lib/boot2docker/:/target jpetazzo/nsenter'
    boot2docker ssh -t sudo "/var/lib/boot2docker/docker-enter \"$1\""
  }
fi
