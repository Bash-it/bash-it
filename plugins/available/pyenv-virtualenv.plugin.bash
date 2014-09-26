# make sure virtualenvwrapper is enabled if available

cite about-plugin
about-plugin 'pyenv-virtualenvwrapper helper functions'

export PYENV_VIRTUALENVWRAPPER_PREFER_PYVENV="true"

# Activate autoenv
source /usr/local/opt/autoenv/activate.sh

function mkenv {
  about 'create a new virtualenv for this directory'
  group 'pyenv-virtualenv'

  eval "touch .env"
  eval "echo \"#!/bin/bash\" >> .env"
  eval "echo \"eval \"wovenv\"\" >> .env"
  cwd=`basename \`pwd\``
  mkvirtualenv --distribute $cwd
}

function mkvbranch {
  about 'create a new virtualenv for the current branch'
  group 'pyenv-virtualenv'

  mkvirtualenv --distribute "$(basename `pwd`)@$SCM_BRANCH"
}

function wovbranch {
  about 'sets workon branch'
  group 'pyenv-virtualenv'

  workon "$(basename `pwd`)@$SCM_BRANCH"
}

function wovenv {
  about 'works on the virtualenv for this directory'
  group 'virtualenv'

  workon "$(basename `pwd`)"
}

function rmenv {
  about 'removes virtualenv for this directory'
  group 'virtualenv'

  eval "deactivate"
  rmvirtualenv "$(basename `pwd`)"
  eval "rm .env"
}

function rmenvbranch {
  about 'removes virtualenv for this directory'
  group 'virtualenv'

  eval "deactivate"
  rmvirtualenv "$(basename `pwd`)@$SCM_BRANCH"
}