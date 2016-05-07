# plugin for plenv

cite about-plugin
about-plugin 'plenv plugin for Perl'

pathmunge "${HOME}/.plenv/bin"

if [[ `which plenv` ]] ; then

  # init plenv
  eval "$(plenv init -)"

  # Load the auto-completion script if it exists.
  [[ -e ~/.plenv/completions/plenv.bash ]] && source ~/.plenv/completions/plenv.bash

else echo "Unable to find plenv. See https://github.com/tokuhirom/plenv for installation"
fi
