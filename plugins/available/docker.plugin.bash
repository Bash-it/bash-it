cite about-plugin
about-plugin 'Helpers to get Docker setup correctly for boot2docker'

# Note, this might need to be different if you have an older version
# of boot2docker, or its configured for a different IP
if [[ `uname -s` == "Darwin" ]]; then
  export DOCKER_HOST=tcp://192.168.59.103:2375
fi
