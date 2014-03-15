# make sure virtualenvwrapper is enabled if available

cite about-plugin
about-plugin 'virtualenvwrapper helper functions'

[[ `which virtualenvwrapper.sh` ]] && . virtualenvwrapper.sh

# default python version - use python2 to pick 
# up Homebrew version if applicable
if hash brew 2>/dev/null && hash python2 2>/dev/null; then
  PYVER="--python=`command -v python2`"
fi

function mkvenv {
  about 'create a new virtualenv for this directory'
  group 'virtualenv'

  cwd=`basename \`pwd\``
  mkvirtualenv $PYVER $cwd
}

function mkvenv3 {
  about 'create a new virtualenv for this directory using python3'
  group 'virtualenv'

  PYVER="--python=`command -v python3`"
  mkvenv
}

function mkvbranch {
  about 'create a new virtualenv for the current branch'
  group 'virtualenv'

  scm_prompt_info >/dev/null 2>&1
  mkvirtualenv $PYVER "$(basename `pwd`)@$SCM_BRANCH"
}

function mkvbranch3 {
  about 'create a new virtualenv for this directory using python3'
  group 'virtualenv'

  PYVER="--python=`command -v python3`"
  mkvbranch
}

function wovbranch {
  about 'sets workon branch'
  group 'virtualenv'

  scm_prompt_info >/dev/null 2>&1
  workon "$(basename `pwd`)@$SCM_BRANCH"
}

function wovenv {
  about 'works on the virtualenv for this directory'
  group 'virtualenv'

  workon "$(basename `pwd`)"
}

function mkve {
  about 'create a new virtualenv with the specified name'
  group 'virtualenv'

  mkvirtualenv $PYVER $1
}

function mkve3 {
  about 'create a new virtualenv with the specified name using python3'
  group 'virtualenv'
  
  PYVER="--python=`command -v python3`" 
  mkve $1
}
