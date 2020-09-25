cite about-plugin
about-plugin 'initializes basher, the shell package manager'

# https://github.com/basherpm/basher

_command_exists basher ||
  [[ -x "$HOME/.basher/bin/basher" ]] ||
  return 0

if ! _command_exists basher && [[ -x "$HOME/.basher/bin/basher" ]] ; then
  pathmunge "$HOME/.basher/bin"
fi

eval "$(basher init - bash)"
