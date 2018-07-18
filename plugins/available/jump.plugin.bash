cite about-plugin
about-plugin 'initialize jump (see https://github.com/gsamokovarov/jump)'

__init_jump() {
  command -v jump &> /dev/null || return
  eval "$(jump shell --bind=z)"
}

__init_jump
