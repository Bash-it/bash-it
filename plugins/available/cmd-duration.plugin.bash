cite about-plugin
about-plugin 'keep track of the moment when the last command started, to be able to compute its duration'

preexec () {
  export BASH_IT_LAST_COMMAND_STARTED=${EPOCHSECONDS:-$(perl -e 'print time()')}
}

preexec_install;
