cite about-plugin
about-plugin 'Helpers to get Docker setup correctly for docker-machine'

# Note, this might need to be different if you use a machine other than 'dev'
if [[ `uname -s` == "Darwin" ]]; then
  # check if dev machine is running
  docker-machine ls | grep --quiet 'dev.*Running'
  if [[ "$?" = "0" ]]; then
    eval "$(docker-machine env dev)"
  fi
fi
