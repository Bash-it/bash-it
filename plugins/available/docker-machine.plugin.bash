cite about-plugin
about-plugin 'Helpers to get Docker setup correctly for docker-machine'

# Note, this might need to be different if you use a machine other than 'dev',
# or its configured for a different IP
if [[ `uname -s` == "Darwin" ]]; then
  eval "$(docker-machine env dev)"
fi
