cite about-plugin
about-plugin 'set textmate as a default editor'

if $(command -v mate &> /dev/null) ; then
  export EDITOR="$(which mate) -w"
  export GIT_EDITOR=$EDITOR
fi
