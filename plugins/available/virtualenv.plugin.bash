# make sure virtualenvwrapper is enabled if available

cite about-plugin
about-plugin 'virtualenvwrapper and pyenv-virtualenvwrapper helper functions'

if _command_exists pyenv; then
  pyenv virtualenvwrapper
else
  [[ `which virtualenvwrapper.sh` ]] && . virtualenvwrapper.sh
fi


function mkvenv {
  about 'create a new virtualenv for this directory'
  group 'virtualenv'

  cwd=`basename \`pwd\``
  mkvirtualenv --distribute $cwd
}


function mkvbranch {
  about 'create a new virtualenv for the current branch'
  group 'virtualenv'

  mkvirtualenv --distribute "$(basename `pwd`)@$SCM_BRANCH"
}

function wovbranch {
  about 'sets workon branch'
  group 'virtualenv'

  workon "$(basename `pwd`)@$SCM_BRANCH"
}

function wovenv {
  about 'works on the virtualenv for this directory'
  group 'virtualenv'

  workon "$(basename `pwd`)"
}
