# make sure virtualenvwrapper is enabled if available

cite about-plugin
about-plugin 'virtualenvwrapper helper functions'

[[ `which virtualenvwrapper.sh` ]] && . virtualenvwrapper.sh


function mkvenv {
  about 'create a new virtualenv for this directory'
  group 'virtualenv'

  cwd=`basename \`pwd\``
  mkvirtualenv --no-site-packages --distribute $cwd
}


function mkvbranch {
  about 'create a new virtualenv for the current branch'
  group 'virtualenv'

  mkvirtualenv --no-site-packages --distribute "$(basename `pwd`)@$(git_prompt_info)"
}

function wovbranch {
  about 'sets workon branch'
  group 'virtualenv'

  workon "$(basename `pwd`)@$(git_prompt_info)"
}
