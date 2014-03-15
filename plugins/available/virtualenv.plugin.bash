# make sure virtualenvwrapper is enabled if available

cite about-plugin
about-plugin 'virtualenvwrapper helper functions'

[[ `which virtualenvwrapper.sh` ]] && . virtualenvwrapper.sh


function mkvenv {
  about 'create a new virtualenv for this directory'
  group 'virtualenv'

  cwd=`basename \`pwd\``
  mkvirtualenv --distribute $cwd
}


function mkvbranch {
  about 'create a new virtualenv for the current branch'
  group 'virtualenv'

  scm_prompt_info >/dev/null 2>&1
  mkvirtualenv --distribute "$(basename `pwd`)@$SCM_BRANCH"
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
