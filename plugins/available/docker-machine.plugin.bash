cite about-plugin
about-plugin 'Helpers to get Docker setup correctly for docker-machine'

# Note, this might need to be different if you use a machine other than 'dev',
# or its configured for a different IP
if [[ `uname -s` == "Darwin" ]]; then
  export DOCKER_HOST="tcp://192.168.99.100:2376"
  export DOCKER_CERT_PATH="$HOME/.docker/machine/machines/dev"
  export DOCKER_TLS_VERIFY=1
  export DOCKER_MACHINE_NAME="dev"
fi
