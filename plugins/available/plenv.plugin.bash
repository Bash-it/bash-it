# plugin for plenv

cite about-plugin
about-plugin 'plenv plugin for Perl'

if [[ -e "${HOME}/.plenv/bin" ]] ; then
  
  # load plenv bin dir into path if it exists
  pathmunge "${HOME}/.plenv/bin"
  
fi

if [[ `which plenv` ]] ; then

  # init plenv
  eval "$(plenv init -)"

  # Load the auto-completion script if it exists.
  [[ -e ~/.plenv/completions/plenv.bash ]] && source ~/.plenv/completions/plenv.bash

fi
