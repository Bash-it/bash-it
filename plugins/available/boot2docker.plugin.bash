# shellcheck shell=bash
cite about-plugin
about-plugin 'Helpers to get Docker setup correctly for boot2docker'

# Note, this might need to be different if you have an older version
# of boot2docker, or its configured for a different IP
if [[ "$OSTYPE" == 'darwin'* ]]; then
	export DOCKER_HOST="tcp://192.168.59.103:2376"
	export DOCKER_CERT_PATH="${HOME}/.boot2docker/certs/boot2docker-vm"
	export DOCKER_TLS_VERIFY=1
fi
